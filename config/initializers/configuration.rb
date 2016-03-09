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
  option_string 'graphite_host', 'GRAPHITE_HOST'
  option_string 'graphite_port', 'GRAPHITE_PORT'
  option_string 'graphite_prefix', 'GRAPHITE_PREFIX'
  option_int 'graphite_slice', 'GRAPHITE_SLICE_IN_SECONDS'
  option_int 'graphite_interval', 'GRAPHITE_CLIENT_INTERVAL_IN_SECONDS'
  option_bool 'metrics_enabled', 'METRICS_ENABLED'
end
