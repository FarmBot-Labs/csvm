# require: request_header

class MessageHandler
  def self.current
    @current ||= self.new
  end

  OP_WIDTH = RequestHeader::SEGMENTS[:OPERATION].width
  NS_WIDTH = RequestHeader::SEGMENTS[:NAMESPACE].width
  PAD_CHAR = RequestHeader::PAD_CHAR

  def self.namespace(name)
    name.ljust(NS_WIDTH, PAD_CHAR)[0, NS_WIDTH]
  end

  def self.operation(name)
    name.ljust(OP_WIDTH, PAD_CHAR)[0, OP_WIDTH]
  end

  DISPATCH_TABLE = {
    "CODE" => {

    },
    "PROC" => {

    }
  }

  def execute(request_header)
    # Validate namespace
    # Validate op
    # pass off control to respective dispatcher class.
  end
end


if RUBY_ENGINE == "ruby"
  require "test-unit"
  require "pry"

  class Test4MessageHandler < Test::Unit::TestCase
    def test_this_plz
      pend("I need to write these")
    end
  end
end
