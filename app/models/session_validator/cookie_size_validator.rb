class SessionValidator
  class CookieSizeValidator
    def validate(_cookies, session)
      # an approximation of how big the session cookie values are
      session_cookie_size = session.to_hash.flatten.to_s.length
      Rails.logger.error("Session cookie is large: #{session_cookie_size}") if session_cookie_size > 3096 # 3Kb
      SuccessfulValidation
    end
  end
end
