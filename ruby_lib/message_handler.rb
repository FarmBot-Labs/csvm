# require: request_header
# stubs for now
module Code
  class Create;end
  class Open;  end
  class Write; end
  class Close; end
  class Rm;    end
  class Start; end
  class Pause; end
  class Kill;  end
  class Run;   end
end

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
    [namespace("CODE"), op("CLOSE") ] => Code::Close,
    [namespace("CODE"), op("CREATE")] => Code::Create,
    [namespace("CODE"), op("KILL")  ] => Code::Kill,
    [namespace("CODE"), op("OPEN")  ] => Code::Open,
    [namespace("CODE"), op("PAUSE") ] => Code::Pause,
    [namespace("CODE"), op("RM")    ] => Code::Rm,
    [namespace("CODE"), op("RUN")   ] => Code::Run,
    [namespace("CODE"), op("START") ] => Code::Start,
    [namespace("CODE"), op("WRITE") ] => Code::Write,
  }

  def self.current
    @current ||= self.new
  end

  def execute(request_header, host)
    find_dispatcher(request_header)
    # Validate namespace
    # Validate op
    # pass off control to respective dispatcher class.
  end

  def find_dispatcher(header)
    lookup_key = [header.namespace, header.operation]
    klass      = DISPATCH_TABLE[lookup_key]
    klass or raise NoDispatcher, lookup_key.join("")
  end
end
