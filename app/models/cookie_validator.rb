class CookieValidator
  def initialize(session_duration)
    @validators = [
      NoCookiesValidator.new,
      MissingCookiesValidator.new,
      SessionStartTimeCookieValidator.new(session_duration)
    ]
  end

  def validate(cookies)
    @validators.lazy.map { |validator| validator.validate(cookies) }.detect { |result| !result.ok? } || SuccessfulValidation
  end
end
