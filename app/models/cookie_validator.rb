class CookieValidator
  def validate(cookies)
    if cookies_missing?(cookies)
      MissingCookiesValidation.new
    else
      Validation.new
    end
  end

  def cookies_missing?(cookies)
    cookies.select { |name, _| CookieNames.session_cookies.include?(name) }.empty?
  end

  class Validation
    def no_cookies?
      false
    end

    def ok?
      true
    end
  end

  class MissingCookiesValidation
    def no_cookies?
      true
    end

    def ok?
      false
    end

    def message
      "No session cookies can be found"
    end
  end
end
