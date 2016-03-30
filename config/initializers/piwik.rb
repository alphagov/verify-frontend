require 'piwik'
require 'analytics'
require 'originating_ip_store'

INTERNAL_PIWIK = Piwik.new(CONFIG.internal_piwik_host, CONFIG.piwik_port, CONFIG.piwik_site_id)
PUBLIC_PIWIK = Piwik.new(CONFIG.public_piwik_host, CONFIG.piwik_port, CONFIG.piwik_site_id)

client = Analytics::PiwikClient.new(INTERNAL_PIWIK.url)
ANALYTICS_REPORTER = Analytics::Reporter.new(client, INTERNAL_PIWIK.site_id)
