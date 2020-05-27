require "securerandom"

# persistent session id is taken from matomo if available, and generated if not
module AnalyticsCookiePartialController
  def analytics_session_id
    cookie_value = cookies.fetch(CookieNames::PERSISTENT_SESSION_ID_COOKIE_NAME, nil)
    if cookie_value.nil?
      matomo_value = cookies.fetch(analytics_cookie_name, nil)
      cookie_value = matomo_value.split(".").first unless matomo_value.nil?
      if cookie_value.nil?
        cookie_value = SecureRandom.uuid
      end
    end
    # analytics session id lasts for 13 months from use - so always refresh the cookie
    cookies[CookieNames::PERSISTENT_SESSION_ID_COOKIE_NAME] = { value: cookie_value, expires: 13.months.from_now }
    cookie_value
  end

private

  def analytics_cookie_name
    cookies.each { |name, _value| return name if name.starts_with? CookieNames::ANALYTICS_SESSION_COOKIE_PREFIX }
  end
end
