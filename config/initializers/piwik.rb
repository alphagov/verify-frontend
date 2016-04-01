require 'piwik'
require 'analytics'
require 'originating_ip_store'

INTERNAL_PIWIK = Piwik.new(CONFIG.internal_piwik_host, CONFIG.piwik_port, CONFIG.piwik_site_id)
PUBLIC_PIWIK = Piwik.new(CONFIG.public_piwik_host, CONFIG.piwik_port, CONFIG.piwik_site_id)

if INTERNAL_PIWIK.enabled?
  client = Analytics::PiwikClient.new(INTERNAL_PIWIK.url, async: Rails.env != 'test')
  ANALYTICS_REPORTER = Analytics::Reporter.new(client, INTERNAL_PIWIK.site_id)
else
  ANALYTICS_REPORTER = Analytics::NullReporter.new
end
