# Datastructure to encapsulate a single request header, as defined in the spec.
# Purpose: Eliminates repetition of common parsing operations, such as
# extracting header names or parsing uint16's into Ruby number types.
class RequestHeader
  attr_reader :input
  class TooShort     < Exception; end
  class BadSegName   < Exception; end
  class BadPayload   < Exception; end
  # Declares the name, width, and starting index of a segment within a request
  # header. See: specification.md for an overview of segments.
  Segment         = Struct.new(:name, :start, :width)
  # Every segment in the sepc, indexed by name.
  SEGMENTS        = [ Segment.new(:CHANNEL,            0,  2),
                      Segment.new(:NAMESPACE,          2,  4),
                      Segment.new(:OPERATION,          6,  5),
                      Segment.new(:PAYLOAD_SIZE_DECLR, 11, 2),
                      Segment.new(:CLRF,               13, 2) ]
                    .map do |s| {s.name => s} end
                    .reduce(:merge)
  # Character used to pad command/namespace segments when the name is smaller
  # than the specified segment size.
  PAD_CHAR        = "_"
  CRLF            = "\r\n"
  # Used by String#unpack() to unpack unsigned 16 bit integers (big endian)
  UINT16          = "S"
  # The size of a request header, excluding the (flexible) payload.
  HEADER_SIZE     = SEGMENTS.values.map { |x| x.width }.reduce(:+)
  MISSING         = "NONE"

  def self.command_list(*commands) # Pad / truncate opnames to correct size.
    width = SEGMENTS[:OPERATION].width
    commands.map { |op| op.ljust(width, PAD_CHAR)[0, width] }
  end

  # Convert ruby Fixnum to UInt16 (binary string)
  def self.uint16(number)
    [number].pack(UINT16)
  end

  attr_reader :input, # Raw input string, as provided by input stream (usually)
              :channel,
              :namespace,
              :operation,
              :payload_size,
              :payload

  # Create a request header without the need for string typing.
  def create(namespace, operation, payload, channel = 1)
    [
      RequestHeader.uint16(channel),
      namespace,
      operation,
      uint16(payload.to_s.length),
      RequestHeader::CRLF,
      payload.to_s
    ].join("")
  end

  def initialize(input)
    @input        = input
    # Prevents NPEs in code below:
    raise TooShort if @input.length < HEADER_SIZE
    @channel      = input[segm(:CHANNEL).start, segm(:CHANNEL).width]
                    .unpack(UINT16)
                    .first
    @namespace    = input[segm(:NAMESPACE).start, segm(:NAMESPACE).width]
    @operation    = input[segm(:OPERATION).start, segm(:OPERATION).width]
    @payload_size = input[segm(:PAYLOAD_SIZE_DECLR).start,
                          segm(:PAYLOAD_SIZE_DECLR).width].unpack(UINT16).first
    @payload      = input.split(CRLF).last
  end

  # Validates syntax but not semantics.
  def validate!
    raise BadPayload unless @payload.length == @payload_size
  end

private

  # Throw runtime error on malformed segment names (catch typos in test suite)
  def segm(name)
    SEGMENTS[name] or raise BadSegName, name
  end
end





# TESTS ==================

if RUBY_ENGINE == "ruby"
  require "test-unit"
  require "pry"
  class Test4RequestHeader < Test::Unit::TestCase

    UINT16 = "S"

    def test_payl_attributes
      chan_id      = RequestHeader.uint16(rand(0..128))
      namespace    = "NS__"
      operation    = "OP___"
      payload      = "12345"
      payload_size = [payload.length].pack(UINT16)
      input        = [chan_id,
                      namespace,
                      operation,
                      payload_size,
                      RequestHeader::CRLF,
                      payload].join("")
      msg          = RequestHeader.new(input)

      assert_equal(msg.channel,        chan_id.unpack(UINT16).first)
      assert_equal(msg.payload.length, payload_size.unpack(UINT16).first)
      assert_equal(msg.namespace,      namespace)
      assert_equal(msg.operation,      operation)
      assert_equal(msg.payload.length, msg.payload_size)
      assert_equal(msg.payload,        payload)
    end

    def test_too_short
      assert_raise(RequestHeader::TooShort) { RequestHeader.new("X").validate! }
    end

    def test_payload_size_validation
      string = [
        RequestHeader.uint16(123),
        "PROC",
        "START",
        RequestHeader.uint16(1),
        RequestHeader::CRLF,
        "123"
      ].join("")

      rh = RequestHeader.new(string)
      assert_raise(RequestHeader::BadPayload) { rh.validate! }
    end
  end
end

