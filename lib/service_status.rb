class ServiceStatus
  def self.unavailable?
    File.exist?(::CONFIG.zdd_file)
  end
end
