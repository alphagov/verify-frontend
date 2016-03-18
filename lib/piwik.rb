require 'uri'

class Piwik
  attr_reader :url, :site_id

  def initialize(config)
    @enabled = config.piwik_host.present?
    if @enabled
      @url = URI.join("#{config.piwik_host}:#{config.piwik_port}", "/piwik.php").to_s
    end
    @site_id = config.piwik_site_id
  end

  def enabled?
    @enabled
  end
end
