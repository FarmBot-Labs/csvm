# require: request_header
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

