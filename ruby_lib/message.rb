class Message
  attr_reader :input

  def initialize(input)
    @input = input
    validate!
  end
end

if RUBY_ENGINE == "ruby"
  require "test-unit"

  class Test4Message < Test::Unit::TestCase
    def test_2_plus_2
      assert(2+2, 4)
    end
  end
end

