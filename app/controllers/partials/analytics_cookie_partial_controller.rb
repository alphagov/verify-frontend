require "securerandom"

# analytics_session_id is disconnected from matomo and generated if not present
module AnalyticsCookiePartialController
  def analytics_session_id
    cookie_value = cookies.fetch(CookieNames::PERSISTENT_SESSION_ID_COOKIE_NAME, nil)
    if cookie_value.nil?
      cookie_value = SecureRandom.uuid
      cookies[CookieNames::PERSISTENT_SESSION_ID_COOKIE_NAME] = { value: cookie_value, expires: 13.months.from_now }
    end
    cookie_value
  end

private

  def analytics_cookie_name
    cookies.each { |name, _value| return name if name.starts_with? CookieNames::ANALYTICS_SESSION_COOKIE_PREFIX }
  end
end
