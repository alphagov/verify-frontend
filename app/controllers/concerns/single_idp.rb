module SingleIdp
  extend ActiveSupport::Concern
  def single_idp_cookie
    MultiJson.load(cookies.encrypted[CookieNames::VERIFY_SINGLE_IDP_JOURNEY])
  rescue MultiJson::ParseError
    nil
  end

  def valid_cookie?
    if single_idp_cookie.nil?
      # This is still valid behaviour, it can be the users session has genuinely expired,
      # or that the session has been tampered with.
      logger.warn "Single IDP cookies was not found or was malformed" + referrer_string
      FEDERATION_REPORTER.report_single_idp_invalid_cookie(
        current_transaction, request
      )
      return false
    end
    true
  end

  def referrer_string
    ' - referrer: ' + (request&.referer || '[could not get the referrer]')
  end
end
