# require: "message_handler"
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

    def test_find_dispatcher_no
      lookup  = ["NO___", "WAY_"]
      request = RequestHeader.create(*lookup)

      assert_raise(MessageHandler::NoDispatcher, lookup.join("")) do
        MessageHandler.current.find_dispatcher(request)
      end
    end

    def test_find_dispatcher_ok
      lookup, expected_klass = MessageHandler::DISPATCH_TABLE.first
      request                = RequestHeader.create(*lookup)
      actual_klass           = MessageHandler.current.find_dispatcher(request)

      assert_equal(expected_klass, actual_klass)
    end

    def test_execute
      lookup, klass = MessageHandler::DISPATCH_TABLE.first
      request       = RequestHeader.create(*lookup)
      result        = MessageHandler.current.execute request, Hypervisor.current
      assert_equal(result.class, klass)
    end
  end
end
