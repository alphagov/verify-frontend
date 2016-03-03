module CookieNames
  SECURE_COOKIE_NAME = "x-govuk-secure-cookie"
  SESSION_ID_COOKIE_NAME = "x_govuk_session_cookie"
  SESSION_STARTED_TIME_COOKIE_NAME = "session_start_time"
  VERIFY_JOURNEY_HINT = "verify-journey-hint"

  def self.session_cookies
    [SECURE_COOKIE_NAME, SESSION_ID_COOKIE_NAME, SESSION_STARTED_TIME_COOKIE_NAME]
  end

  def self.all_cookies
    session_cookies.push VERIFY_JOURNEY_HINT
  end
end
