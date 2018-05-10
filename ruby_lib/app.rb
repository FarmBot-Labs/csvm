# require: message_handler

class App
  def current
    @current ||= self.new
  end

  def run!
    # Main run loops
    until STDIN.eof?
      # Check for inbound stuff, esp. signals.
      current_message = InputManager.current.shift
      if current_message
        message = RequestHeader.new(current_message)
        MessageHandler.current.execute(message, self)
      else
        HyperVisor.current.tick_next_process
      end
      # (possibly) act on signals
      # Act on other stuff
      # perform next round robin tick
    end
  end
end
