# require: "message_handler"
# require: "input_manager"
# require: "hypervisor"

class App
  def self.current
    @current ||= self.new
  end

  def run(input_manager)
    # Main run loops
    loop do
      data = input_manager.shift
      if data
        puts data.inspect
        message = RequestHeader.new(data)
        MessageHandler.current.execute(message, Hypervisor.current)
      else
        Hypervisor.current.tick
      end
    end
  end
end
