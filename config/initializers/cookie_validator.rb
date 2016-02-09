session_cookie_duration_in_hours = ENV.fetch("SESSION_COOKIE_DURATION_IN_HOURS") do 
  raise "A session cookie duration must be provided via SESSION_COOKIE_DURATION_IN_HOURS"
end
COOKIE_VALIDATOR = CookieValidator.new(Integer(session_cookie_duration_in_hours))
