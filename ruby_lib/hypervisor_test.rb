# require: "hypervisor"

if RUBY_ENGINE == "ruby"
  require "test-unit"
  require "pry"

  class Test4Hypervisor < Test::Unit::TestCase
    def test_current
      assert_equal(Hypervisor.current, Hypervisor.current)
      assert_equal(Hypervisor.current.class, Hypervisor)
    end
  end
end
