class SamlController < ApplicationController
  protect_from_forgery except: [:request_post, :response_post]
  skip_before_action :validate_cookies

  SIGNING_IN_STATE = 'SIGN_IN_WITH_IDP'.freeze
  REGISTERING_STATE = 'REGISTER_WITH_IDP'.freeze

  def request_post
    reset_session
    response = SESSION_PROXY.create_session(params['SAMLRequest'], params['RelayState'])

    set_secure_cookie(CookieNames::SESSION_STARTED_TIME_COOKIE_NAME, response.session_start_time)
    set_secure_cookie(CookieNames::SESSION_ID_COOKIE_NAME, response.session_id)
    set_secure_cookie(CookieNames::SECURE_COOKIE_NAME, response.secure_cookie)
    session[:transaction_simple_id] = response.transaction_simple_id

    if params['journey_hint'].present?
      redirect_to internationalise_route('confirm_your_identity')
    else
      redirect_to internationalise_route('start')
    end
  end

  def response_post
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

private

  def locale_from_journey_hint
    journey_hint_value.nil? ? I18n.default_locale : journey_hint_value['locale'].to_sym
  end

  # We can't set the I18n.locale value after it has already been set in ApplicationController due to the bug detailed
  # here:
  #    https://github.com/svenfuchs/i18n/issues/275
  def internationalise_route(key)
    "/#{I18n.t('routes.' + key, locale: locale_from_journey_hint)}"
  end
end
