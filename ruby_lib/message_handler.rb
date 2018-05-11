# require: "dispatchers/__main.rb"
# require: "request_header"

puts ("=" * 10) + "MessageHandler"
class MessageHandler # TODO: Rename to "MessageRouter"
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
    find_dispatcher(request_header).new.call(host)
  end

  def find_dispatcher(header)
    lookup_key = [header.namespace, header.operation]
    klass      = DISPATCH_TABLE[lookup_key]
    klass or raise NoDispatcher, lookup_key.join("")
  end
end
