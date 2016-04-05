class SamlController < ApplicationController
  protect_from_forgery except: :request_post
  skip_before_action :validate_cookies

  def request_post
    cookies_from_api = authn_request_proxy.create_session(params['SAMLRequest'], params['RelayState'])
    cookies_from_api.each { |name, value| set_secure_cookie(name, value) }
    if params['journey_hint'].present?
      redirect_to confirm_your_identity_path
    else
      redirect_to start_path
    end
  end

private

  def authn_request_proxy
    SESSION_PROXY
  end
end
