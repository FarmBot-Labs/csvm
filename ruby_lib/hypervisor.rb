class Hypervisor
  def self.current
    @current ||= self.new
  end
end
