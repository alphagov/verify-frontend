session_cookie_duration_in_hours = CONFIG.session_cookie_duration

Rails.application.config.to_prepare do
  COOKIE_VALIDATOR = CookieValidator.new(Integer(session_cookie_duration_in_hours))
end
