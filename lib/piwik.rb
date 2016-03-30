require 'uri'

class Piwik
  attr_reader :url, :site_id

  def initialize(host, port, site_id)
    @enabled = host.present?
    if @enabled
      @url = URI.join("#{host}:#{port}", "/piwik.php")
    end
    @site_id = site_id
  end

  def enabled?
    @enabled
  end
end
