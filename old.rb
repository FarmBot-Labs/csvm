module Code
  class Create
    def call(request, hypervisor)
      raise "NOT IMPLEMENTED"
    end
  end
end

module Code
  class Close
    def call(request, hypervisor) # THATS A CLOSE CALL!
      # raise "NOT IMPLEMENTED"
      self
    end
  end
end

module Code
  class Open
    def call(request, hypervisor)
      raise "NOT IMPLEMENTED"
    end
  end
end

module Code
  class Rm
    def call(request, hypervisor)
      raise "NOT IMPLEMENTED"
    end
  end
end

module Code
  class Write
    def call(request, hypervisor)
      raise "NOT IMPLEMENTED"
    end
  end
end

# require: "create"
# require: "close"
# require: "open"
# require: "rm"
# require: "write"


module Prok
  class Kill
    def call(request, hypervisor)
      raise "NOT IMPLEMENTED"
    end
  end
end

module Prok
  class Pause
    def call(request, hypervisor)
      raise "NOT IMPLEMENTED"
    end
  end
end

module Prok
  class Run
    def call(request, hypervisor)
      raise "NOT IMPLEMENTED"
    end
  end
end

module Prok
  class Start
    def call(request, hypervisor)
      raise "NOT IMPLEMENTED"
    end
  end
end

# require: "kill"
# require: "pause"
# require: "run"
# require: "start"

# require: "code/__main"
# require: "prok/__main"


# Datastructure to encapsulate a single request header, as defined in the spec.
# Purpose: Eliminates repetition of common parsing operations, such as
# extracting header names or parsing uint16's into Ruby number types.
class RequestHeader
  class TooShort   < Exception; end
  class BadSegName < Exception; end
  class BadPayload < Exception; end
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
    width = segm(:OPERATION).width
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

  # (helper) Create a request header without the need for string typing.
  def self.create(namespace, operation, channel = 1, payload = "")
    payl = [
      RequestHeader.uint16(channel),
      namespace,
      operation,
      uint16(payload.to_s.length),
      RequestHeader::CRLF,
      payload.to_s
    ].join("")
    self.new(payl)
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

# require: "dispatchers/__main.rb"
# require: "request_header"

class MessageHandler
  class NoDispatcher < Exception; end

  OP_WIDTH = RequestHeader::SEGMENTS[:OPERATION].width
  NS_WIDTH = RequestHeader::SEGMENTS[:NAMESPACE].width
  PAD_CHAR = RequestHeader::PAD_CHAR

  def self.namespace(name)
    name.ljust(NS_WIDTH, PAD_CHAR)[0, NS_WIDTH]
  end

  def self.op(name)
    name.ljust(OP_WIDTH, PAD_CHAR)[0, OP_WIDTH]
  end

  DISPATCH_TABLE = {
    # Code Management
    [namespace("CODE"), op("CLOSE") ] => Code::Close,
    [namespace("CODE"), op("CREATE")] => Code::Create,
    [namespace("CODE"), op("OPEN")  ] => Code::Open,
    [namespace("CODE"), op("RM")    ] => Code::Rm,
    [namespace("CODE"), op("WRITE") ] => Code::Write,

    # Process management
    [namespace("PROC"), op("KILL")  ] => Prok::Kill,
    [namespace("PROC"), op("PAUSE") ] => Prok::Pause,
    [namespace("PROC"), op("RUN")   ] => Prok::Run,
    [namespace("PROC"), op("START") ] => Prok::Start
  }

  def self.current
    @current ||= self.new
  end

  def execute(request_header, host)
    dispatcher = find_dispatcher(request_header).new
    result     = dispatcher.call(request_header, host)
    raise "Expected dispatcher to return self" unless result == dispatcher
    result
  end

  def find_dispatcher(header)
    lookup_key = [header.namespace, header.operation]
    klass      = DISPATCH_TABLE[lookup_key]
    klass or raise NoDispatcher, lookup_key.join("")
  end
end

# The Input Manager provides a queue for non-blocking reads of IO objects such as
# $stdin.
class InputManager
  attr_reader :input

  def initialize(input, queue)
    @input = input
    @queue = queue
  end

  def shift
    return (@queue.size > 0) ? @queue.shift : nil
  end

  def check_input_io
    data = self.input.gets.chomp
    @queue.push(data)
  end
end

class Hypervisor
  def self.current
    @current ||= self.new
  end

  def tick
    sleep 1
    puts "Ticking VM!!!!"
  end
end

# require: "message_handler"
# require: "input_manager"
# require: "hypervisor"

class App
  def self.current
    @current ||= self.new
  end

  def run(input_manager)
    # Main run loops
    loop do
      data = input_manager.shift
      if data
        puts data.inspect
        message = RequestHeader.new(data)
        MessageHandler.current.execute(message, Hypervisor.current)
      else
        Hypervisor.current.tick
      end
    end
  end
end

# require: "app"

$q = []
io = InputManager.new($stdin, $q)
Thread.new do
  while true
    $io.check_input_io
  end
end

App.current.run(io)


class MyContainer
  attr_accessor :data
  def initialize(d = nil)
    @data = d
    super
  end
end

$mutex = Mutex.new
$queue = MyContainer.new(1)
$ary = []

svr = Thread.new($queue, $mutex, $ary) do |q, m, a|
  20.times do |i|
    q.data = q.data + 1
    a << q.data
    a.shift if a.size > 3
    Thread.sleep 2
  end
end

while true do
  puts "count = #{$queue.data}, ary = #{$ary}"
  if $queue.data > 10 then
    svr.kill
    break
  end
  Thread.sleep 1
end
