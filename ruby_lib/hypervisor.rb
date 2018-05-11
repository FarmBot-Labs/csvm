class Hypervisor
  def self.current
    @current ||= self.new
  end

  def tick
    raise "NOT IMPL!"
  end
end
