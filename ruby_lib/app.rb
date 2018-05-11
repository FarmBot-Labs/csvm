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
      message = RequestHeader.new(STDIN.gets)
      MessageHandler.current.execute(message, Hypervisor.current)
    end
  end
end
