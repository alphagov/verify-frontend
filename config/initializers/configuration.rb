require 'configuration'
CONFIG = Configuration.load! do
  option_string 'rp_display_locales', 'RP_DISPLAY_LOCALES'
  option_string 'idp_display_locales', 'IDP_DISPLAY_LOCALES'
  option_string 'session_cookie_duration', 'SESSION_COOKIE_DURATION_IN_HOURS'
  option_string 'api_host', 'API_HOST'
  option_string 'logo_directory', 'LOGO_DIRECTORY'
  option_string 'zdd_file', 'ZDD_LATCH'
  option_string 'polling_wait_time', 'POLLING_WAIT_TIME'
  option_string 'api_cert_path', 'API_CERT_PATH', allow_missing: true
  option_string 'statsd_host', 'STATSD_HOST'
  option_string 'statsd_port', 'STATSD_PORT'
  option_string 'statsd_prefix', 'STATSD_PREFIX'
  option_int 'statsd_slice', 'STATSD_SLICE_IN_SECONDS'
  option_int 'statsd_interval', 'STATSD_CLIENT_INTERVAL_IN_SECONDS'
  option_bool 'metrics_enabled', 'METRICS_ENABLED'
  option_string 'piwik_host', 'PIWIK_HOST', allow_missing: true
  option_int 'piwik_port', 'PIWIK_PORT', default: 443
  option_int 'piwik_site_id', 'PIWIK_SITE_ID', default: 1
end
