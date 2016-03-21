require 'piwik'
require 'analytics'
require 'ssl_context_factory'

PIWIK = Piwik.new(CONFIG)

context = SSLContextFactory.new.create_context(
  cert_path: CONFIG.analytics_cert_path
)
client = Analytics::PiwikClient.new(context)
ANALYTICS_REPORTER = Analytics::Reporter.new(client, PIWIK.site_id)
