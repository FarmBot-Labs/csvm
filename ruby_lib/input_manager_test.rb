# require: input_manager

if RUBY_ENGINE == "ruby"
  require "test-unit"
  require "pry"

  class Test4InputManager < Test::Unit::TestCase
    def test_this_plz
      seriously = "I need to write these"
      assert_equal(seriously, seriously)
    end
  end
end
