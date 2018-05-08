# The Input Manager provides a queue for non-blocking reads of IO objects such as
# $stdin.
class InputManager < Queue
  attr_reader :input
  # Crash fast if the following classes are missing.
  THREAD = Thread
  QUEUE  = Queue
  INPUT  = $stdin

  def self.current
    @current ||= self.new
  end

  def initialize(input = INPUT)
    @input  = input
    @queue  = QUEUE.new
    @thread = THREAD.new { loop { check_input_io } }
  end

  def shift
    return (@queue.size > 0) ? @queue.shift : nil
  end

  def check_input_io
    data = self.input.gets
    puts "[STDIN] #{data}"
    @queue.push(data)
  end
end
