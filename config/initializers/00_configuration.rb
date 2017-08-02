require 'configuration'

CONFIG = Configuration.load! do
  option_string 'product_page_url', 'VERIFY_PRODUCT_PAGE', default: 'https://govuk-verify.cloudapps.digital/'
  option_string 'rp_display_locales', 'RP_DISPLAY_LOCALES'
  option_string 'cycle_3_display_locales', 'CYCLE_3_DISPLAY_LOCALES'
  option_string 'idp_display_locales', 'IDP_DISPLAY_LOCALES'
  option_string 'country_display_locales', 'COUNTRY_DISPLAY_LOCALES'
  option_string 'session_cookie_duration', 'SESSION_COOKIE_DURATION_IN_HOURS', default: 2
  option_string 'api_host', 'API_HOST'
  option_string 'logo_directory', 'LOGO_DIRECTORY'
  option_string 'white_logo_directory', 'WHITE_LOGO_DIRECTORY'
  option_string 'zdd_file', 'ZDD_LATCH'
  option_string 'polling_wait_time', 'POLLING_WAIT_TIME', default: 6
  option_bool 'metrics_enabled', 'METRICS_ENABLED', default: true
  if metrics_enabled
    option_string 'statsd_host', 'STATSD_HOST', default: '127.0.0.1'
    option_string 'statsd_port', 'STATSD_PORT', default: 8125
    option_string 'statsd_prefix', 'STATSD_PREFIX'
  end
  option_string 'internal_piwik_host', 'INTERNAL_PIWIK_HOST', allow_missing: true
  option_string 'public_piwik_host', 'PUBLIC_PIWIK_HOST', allow_missing: true
  option_int 'piwik_site_id', 'PIWIK_SITE_ID', default: 1
  option_int 'read_timeout', 'READ_TIMEOUT', default: 60
  option_int 'connect_timeout', 'CONNECT_TIMEOUT', default: 4
  option_string 'rules_directory', 'RULES_DIRECTORY'
  option_string 'rules_directory_b', 'RULES_DIRECTORY_B'
  option_string 'zendesk_url', 'ZENDESK_URL'
  option_string 'zendesk_username', 'ZENDESK_USERNAME'
  option_string 'zendesk_token', 'ZENDESK_TOKEN'
  option_string 'zendesk_proxy', 'ZENDESK_PROXY', allow_missing: true
  option_string 'rp_config', 'RP_CONFIG'
  option_string 'idp_config', 'IDP_CONFIG'
  option_string 'cycle_three_attributes_directory', 'CYCLE_THREE_ATTRIBUTES_DIRECTORY'
  option_string 'ab_test_file', 'AB_TEST_FILE', allow_missing: true
  option_string 'saml_proxy_host', 'SAML_PROXY_HOST'
end
