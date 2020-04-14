module AnalyticsCookiePartialController
  def analytics_session_id
    cookie_value = cookies.fetch(analytics_cookie_name, nil)
    cookie_value.split(".").first unless cookie_value.nil?
  end

private

  def analytics_cookie_name
    cookies.each { |name, _value| return name if name.starts_with? CookieNames::ANALYTICS_SESSION_COOKIE_PREFIX }
  end
end
