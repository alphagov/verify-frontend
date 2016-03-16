class Piwik
  attr_reader :url, :site_id

  def initialize(config)
    @enabled = config.piwik_host.present?
    @url = "#{config.piwik_host}:#{config.piwik_port}/piwik.php"
    @site_id = config.piwik_site_id
  end

  def enabled?
    @enabled
  end
end
