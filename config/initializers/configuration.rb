require 'configuration'
CONFIG = Configuration.load! do
  option 'rp_display_locales', 'RP_DISPLAY_LOCALES'
  option 'idp_display_locales', 'IDP_DISPLAY_LOCALES'
  option 'session_cookie_duration', 'SESSION_COOKIE_DURATION_IN_HOURS'
  option 'api_host', 'API_HOST'
  option 'logo_directory', 'LOGO_DIRECTORY'
  option 'zdd_file', 'ZDD_LATCH'
  option 'polling_wait_time', 'POLLING_WAIT_TIME'
end
