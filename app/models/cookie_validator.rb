class CookieValidator
  def initialize(session_duration)
    @validators = [
      NoCookiesValidator.new,
      MissingCookiesValidator.new,
      SessionIdCookieValidator.new,
      TransactionSimpleIdPresence.new,
      SessionStartTimeCookieValidator.new(session_duration)
    ]
  end

  def validate(cookies, session)
    @validators.lazy.map { |validator| validator.validate(cookies, session) }.detect(&:bad?) || SuccessfulValidation
  end
end
