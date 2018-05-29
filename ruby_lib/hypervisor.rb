class Hypervisor
  def self.current
    @current ||= self.new
  end

  def tick
    sleep 1
    puts "Ticking VM!!!!"
  end
end
