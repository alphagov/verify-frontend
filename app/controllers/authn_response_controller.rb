class AuthnResponseController < ApplicationController
  protect_from_forgery except: :idp_response
  skip_before_action :validate_cookies

  SIGNING_IN_STATE = 'SIGN_IN_WITH_IDP'.freeze
  REGISTERING_STATE = 'REGISTER_WITH_IDP'.freeze

  def set_locale
    I18n.locale = locale_from_journey_hint
  end

  def idp_response
    if params['RelayState'] != cookies[CookieNames::SESSION_ID_COOKIE_NAME]
      raise StandardError, 'Relay state should match session id'
    end

    response = SESSION_PROXY.idp_authn_response(cookies, params['SAMLResponse'], params['RelayState'])
    user_state = response.is_registration ? REGISTERING_STATE : SIGNING_IN_STATE

    case response.idp_result
    when 'SUCCESS'
      ANALYTICS_REPORTER.report(request, "Success - #{user_state}")
      redirect_to response.is_registration ? confirmation_path : response_processing_path
    when 'CANCEL'
      ANALYTICS_REPORTER.report(request, "Cancel - #{user_state}")
      redirect_to start_path
    else
      ANALYTICS_REPORTER.report(request, "Failure - #{user_state}")
      redirect_to response.is_registration ? failed_registration_path : failed_sign_in_path
    end
  end
end
