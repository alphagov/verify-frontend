class Piwik
  attr_reader :url

  def initialize(config)
    @enabled = config.piwik_host.present?
    @url = "#{config.piwik_host}:#{config.piwik_port}/piwik.php"
  end

  def enabled?
    @enabled
  end
end
