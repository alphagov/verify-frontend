class SamlController < ApplicationController
  protect_from_forgery except: :request_post
  skip_before_action :validate_cookies

  def request_post
    cookies_from_api = authn_request_proxy.create_session(params['SAMLRequest'], params['RelayState'])
    cookies_hash = CookieFactory.new(Rails.configuration.x.cookies.secure).create(cookies_from_api)
    cookies_hash.each { |name, value| cookies[name] = value }
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
