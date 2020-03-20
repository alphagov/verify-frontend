require 'configuration'

FED_CONFIG_DIR = '/usr/share/verify-frontend-federation-config'.freeze

CONFIG = Configuration.load! do
  option_string 'product_page_url', 'VERIFY_PRODUCT_PAGE', default: 'https://govuk-verify.cloudapps.digital/'
  option_string 'cycle_3_display_locales', 'CYCLE_3_DISPLAY_LOCALES', default: "#{FED_CONFIG_DIR}/display-locales/cycle_3/"
  option_string 'idp_display_locales', 'IDP_DISPLAY_LOCALES', default: "#{FED_CONFIG_DIR}/display-locales/idps/"
  option_string 'country_display_locales', 'COUNTRY_DISPLAY_LOCALES', default: "#{FED_CONFIG_DIR}/display-locales/countries/"
  option_string 'country_flags_directory', 'COUNTRY_FLAGS_DIRECTORY', default: '/eidas/country-flags'
  option_string 'eidas_schemes_directory', 'EIDAS_SCHEMES_DIRECTORY', default: "#{FED_CONFIG_DIR}/eidas/schemes/"
  option_string 'eidas_scheme_logos_directory', 'EIDAS_SCHEME_LOGOS_DIRECTORY', default: '/eidas/scheme-logos'
  option_string 'session_cookie_duration', 'SESSION_COOKIE_DURATION_IN_HOURS', default: 2
  option_string 'config_api_host', 'CONFIG_API_HOST'
  option_string 'policy_host', 'POLICY_HOST'
  option_string 'logo_directory', 'LOGO_DIRECTORY', default: '/idp-logos'
  option_string 'zdd_file', 'ZDD_LATCH'
  option_bool 'prometheus_enabled', 'PROMETHEUS_ENABLED', default: true
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

  option_int 'hide_idps_disconnecting_for_registration_minutes_before', 'HIDE_IDPS_DISCONNECTING_FOR_REGISTRATION_MINUTES_BEFORE', default: 15

  option_string 'rules_directory', 'RULES_DIRECTORY', default: "#{FED_CONFIG_DIR}/idp-rules/"
  option_string 'segment_definitions', 'SEGMENT_DEFINITIONS', default: "#{FED_CONFIG_DIR}/segment_definitions.yml"

  # begin abc-testing-modifications
  option_string 'abc_variants_config', 'ABC_VARIANTS_CONFIG', default: "#{FED_CONFIG_DIR}/special-cases/abc-variants.yml"
  option_string 'rules_variant_c_directory', 'RULES_C_DIRECTORY', default: "#{FED_CONFIG_DIR}/idp-rules-variant-c/"
  option_string 'segment_definitions_variant_c', 'SEGMENT_DEFINITIONS_VARIANT_C', default: "#{FED_CONFIG_DIR}/segment_definitions_variant_c.yml"
  # end abc-testing-modifications

  option_string 'zendesk_url', 'ZENDESK_URL'
  option_string 'zendesk_username', 'ZENDESK_USERNAME'
  option_string 'zendesk_token', 'ZENDESK_TOKEN'
  option_string 'zendesk_proxy', 'ZENDESK_PROXY', allow_missing: true
  option_string 'rp_config', 'RP_CONFIG', default: "#{FED_CONFIG_DIR}/relying_parties.yml"
  option_string 'cycle_three_attributes_directory', 'CYCLE_THREE_ATTRIBUTES_DIRECTORY', default: "#{FED_CONFIG_DIR}/cycle-three-attributes/"
  option_string 'ab_test_file', 'AB_TEST_FILE', allow_missing: true


  option_string 'saml_proxy_host', 'SAML_PROXY_HOST'
  option_bool 'feedback_disabled', 'FEEDBACK_DISABLED', default: false
  # Feature flags
  option_bool 'single_idp_feature', 'SINGLE_IDP_FEATURE', default: true
  option_bool 'publish_hub_config_enabled', 'PUBLISH_HUB_CONFIG_ENABLED', default: false

  option_string 'cross_gov_google_analytics_tracker_id', 'CROSS_GOV_GOOGLE_ANALYTICS_TRACKER_ID', allow_missing: true
  option_string 'cross_gov_domain_list', 'CROSS_GOV_GOOGLE_ANALYTICS_DOMAIN_LIST', allow_missing: true

  # Enables dev/test routes when compiled for a production env (i.e. when RAILS_ENV=production)
  option_bool 'stub_mode', 'STUB_MODE', default: false
end
