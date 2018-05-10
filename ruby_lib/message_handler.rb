# require: request_header
# stubs for now
module Code
  class Create; end
  class Open;   end
  class Write;  end
  class Close;  end
  class Rm;     end
  class Start;  end
  class Pause;  end
  class Kill;   end
  class Run;    end
end

class MessageHandler
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
    namespace("CODE") =>  { op("CREATE") => Code::Create,
                            op("OPEN")   => Code::Open,
                            op("WRITE")  => Code::Write,
                            op("CLOSE")  => Code::Close,
                            op("RM")     => Code::Rm,
                            op("START")  => Code::Start,
                            op("PAUSE")  => Code::Pause,
                            op("KILL")   => Code::Kill,
                            op("RUN")    => Code::Run, },
    namespace("PROC") => {}
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

private

  def find_dispatcher(header)
    raise "NOT IMPL"
  end
end


if RUBY_ENGINE == "ruby"
  require "test-unit"
  require "pry"

  class Test4MessageHandler < Test::Unit::TestCase
    def test_op
      assert_equal "RM___", MessageHandler.op("RM")
    end

    def test_namespace
      assert_equal "HEYO", MessageHandler.namespace("HEYOO")
    end
  end
end
