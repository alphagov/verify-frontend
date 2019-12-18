module CookieNames
  SESSION_COOKIE_NAME = '_verify-frontend_session'.freeze
  SESSION_ID_COOKIE_NAME = 'x_govuk_session_cookie'.freeze
  VERIFY_FRONT_JOURNEY_HINT = 'verify-front-journey-hint'.freeze
  VERIFY_SINGLE_IDP_JOURNEY = 'verify-single-idp-journey'.freeze
  VERIFY_LOCALE = 'x_verify_locale'.freeze
  PIWIK_USER_ID = 'PIWIK_USER_ID'.freeze
  NO_CURRENT_SESSION_VALUE = 'no-current-session'.freeze
  AB_TEST = 'ab_test'.freeze
  AB_TEST_TRIAL = 'ab_test_trial'.freeze
  MATOMO_COOKIE_PREFIX = '_pk'.freeze
  ANALYTICS_SESSION_COOKIE_PREFIX = MATOMO_COOKIE_PREFIX + '_id.'.freeze

  def self.session_cookies
    [SESSION_ID_COOKIE_NAME, SESSION_COOKIE_NAME]
  end

  def self.all_cookies
    session_cookies.push VERIFY_FRONT_JOURNEY_HINT
  end
end
