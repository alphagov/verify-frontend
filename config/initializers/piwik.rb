require 'piwik'
require 'analytics'
require 'ssl_context_factory'

INTERNAL_PIWIK = Piwik.new(CONFIG.internal_piwik_host, CONFIG.piwik_port, CONFIG.piwik_site_id)
PUBLIC_PIWIK = Piwik.new(CONFIG.public_piwik_host, CONFIG.piwik_port, CONFIG.piwik_site_id)

context = SSLContextFactory.new.create_context(
  cert_path: CONFIG.analytics_cert_path
)
client = Analytics::PiwikClient.new(INTERNAL_PIWIK.url, context)
ANALYTICS_REPORTER = Analytics::Reporter.new(client, INTERNAL_PIWIK.site_id)
