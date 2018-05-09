class MessageHandler
  def self.current
    @current ||= self.new
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
