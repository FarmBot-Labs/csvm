# require: "message_handler"
# require: "input_manager"
# require: "hypervisor"

class App
  def self.current
    @current ||= self.new
  end

  def run
    # Main run loops
    loop do
      # Check for inbound messages, esp. signals.
      current_message = InputManager.current.shift
      if current_message
        message = RequestHeader.new(current_message)
        MessageHandler.current.execute(message, Hypervisor.current)
      else
        Hypervisor.current.tick
      end
    end
  end
end
