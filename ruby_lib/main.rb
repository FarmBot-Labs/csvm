class InputQueue
  def self.current
    @current ||= self.new
  end
end

class HyperVisor
  def self.current
    @current ||= self.new
  end

  # Ticks the next process eligible for round robin work.
  def tick_next_process
    raise "NOT IMPL"
  end
end

class MessageParser
  def initialize
  end

  def parse
    return Command.new # Stub
  end
end

class Command
  def initialize
    raise "NOT IMPL"
  end

  def run!
  end
end

# Main run loops
until STDIN.eof?
  # Check for inbound stuff, esp. signals.
  current_message = InputQueue.current.get
  if current_message
    MessageParser.new(current_message).parse.run!
  else
    HyperVisor.current.tick_next_process
  end
  # (possibly) act on signals
  # Act on other stuff
  # perform next round robin tick
end
