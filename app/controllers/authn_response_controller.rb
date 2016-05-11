class AuthnResponseController < ApplicationController
  protect_from_forgery except: :idp_response
  skip_before_action :validate_cookies

  SIGNING_IN_STATE = 'SIGN_IN_WITH_IDP'.freeze
  REGISTERING_STATE = 'REGISTER_WITH_IDP'.freeze

  def idp_response
    if params['RelayState'] != cookies[CookieNames::SESSION_ID_COOKIE_NAME]
      raise StandardError, 'Relay state should match session id'
    end

    response = SESSION_PROXY.idp_authn_response(cookies, params['SAMLResponse'], params['RelayState'])
    user_state = response.is_registration ? REGISTERING_STATE : SIGNING_IN_STATE
    case response.idp_result
    when 'SUCCESS'
      ANALYTICS_REPORTER.report(request, "Success - #{user_state}")
      if response.is_registration
        redirect_to confirmation_path
      else
        redirect_to response_processing_path
      end
    when 'CANCEL'
      ANALYTICS_REPORTER.report(request, "Cancel - #{user_state}")
      redirect_to internationalise_route('start')
    else
      ANALYTICS_REPORTER.report(request, "Failure - #{user_state}")
      if response.is_registration
        redirect_to failed_registration_path
      else
        redirect_to failed_sign_in_path
      end
    end
  end
end
