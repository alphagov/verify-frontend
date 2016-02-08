module CookieNames
  SECURE_COOKIE_NAME = "x-govuk-secure-cookie"
  SESSION_ID_COOKIE_NAME = "x_govuk_session_cookie"
  SESSION_STARTED_TIME_COOKIE_NAME = "session_start_time"

  def self.session_cookies
    [SECURE_COOKIE_NAME, SESSION_ID_COOKIE_NAME, SESSION_STARTED_TIME_COOKIE_NAME]
  end
end
