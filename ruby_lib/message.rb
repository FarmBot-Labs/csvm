class Message
  attr_reader :input
  class TooShort < Exception; end

  COMMAND_WIDTH   = 5
  COMMAND_PADDING = "_"

  def self.command_list(*commands)
    commands.map do |op|
      op.ljust(COMMAND_WIDTH, COMMAND_PADDING)
    end
  end

  OPERATIONS = {"CODE" => command_list("NEW", "OPEN", "WRITE", "CLOSE", "RM"),
                "PROC" => command_list("START", "PAUSE", "KILL", "RUN")}

  attr_reader :channel_id, :payload, :namespace, :operation, :payload

  def initialize(input)
  end

  # Validates syntax but not semantics.
  def validate!
  end

private

end

if RUBY_ENGINE == "ruby"
  require "test-unit"
  require "pry"
  class Test4Message < Test::Unit::TestCase

    UINT16 = "S"

    def random_uint16
      [rand(0..6553)].pack(UINT16)
    end

    def random_garbage(size)
      [*(0..size)].map { (65 + rand(26)).chr }.join
    end

    def test_too_short
      pend("Ready to implement")
      assert_raise(Message::TooShort) { Message.new("X").validate! }
    end

    def test_attributes
      pend("Ready to implement")
      chan_id      = random_uint16
      payload_size = random_uint16
      namespace    = Message::OPERATIONS.keys.sample
      operation    = Message::OPERATIONS[namespace].sample
      payload      = random_garbage(payload_size.unpack(UINT16).first)
      input        = \
        chan_id + payload_size + namespace + operation + payload + input
      msg          = Message.new(input)
      msg.validate!
      assert_equal(msg.channel_id,     chan_id.unpack(UINT16))
      assert_equal(msg.payload.length, payload_size.unpack(UINT16))
      assert_equal(msg.namespace,      namespace)
      assert_equal(msg.operation,      operation)
      assert_equal(msg.payload,        payload)
    end
  end
end

