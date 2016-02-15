class CookieValidator
  class NoCookiesValidator
    def validate(cookies)
      if all_cookies_missing?(cookies)
        ValidationFailure.no_cookies
      else
        SuccessfulValidation
      end
    end

  private

    def all_cookies_missing?(cookies)
      cookies.select { |name, _| ::CookieNames.session_cookies.include?(name) }.empty?
    end
  end
end
