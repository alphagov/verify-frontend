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
  option_string 'piwik_host', 'PIWIK_HOST', allow_missing: true
  option_int 'piwik_port', 'PIWIK_PORT', default: 443
end
