# The Input Manager provides a queue for non-blocking reads of IO objects such as
# $stdin.
class InputManager
  attr_reader :input

  def initialize(input, queue)
    @input = input
    @queue = queue
  end

  def shift
    return (@queue.size > 0) ? @queue.shift : nil
  end

  def check_input_io
    data = self.input.gets.chomp
    @queue.push(data)
  end
end
