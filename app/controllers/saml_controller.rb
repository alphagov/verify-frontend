class SamlController < ApplicationController
  protect_from_forgery except: :request_post
  skip_before_action :validate_cookies

  def request_post
    reset_session
    response = SESSION_PROXY.create_session(params['SAMLRequest'], params['RelayState'])

    set_secure_cookie(CookieNames::SESSION_STARTED_TIME_COOKIE_NAME, response.session_start_time)
    set_secure_cookie(CookieNames::SESSION_ID_COOKIE_NAME, response.session_id)
    set_secure_cookie(CookieNames::SECURE_COOKIE_NAME, response.secure_cookie)
    session[:transaction_simple_id] = response.transaction_simple_id

    # We can't set the I18n.locale value after it has already been set in ApplicationController due to the bug detailed
    # here:
    #    https://github.com/svenfuchs/i18n/issues/275
    locale = journey_hint_value.nil? ? I18n.default_locale : journey_hint_value['locale'].to_sym

    if params['journey_hint'].present?
      redirect_to "/#{I18n.t('routes.confirm_your_identity', locale: locale)}"
    else
      redirect_to "/#{I18n.t('routes.start', locale: locale)}"
    end
  end

  def response_post
    SESSION_PROXY.idp_authn_response(params['SAMLResponse'], params['RelayState'])
    redirect_to confirmation_path
  end
end
