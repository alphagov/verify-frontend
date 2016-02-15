class SamlController < ApplicationController
  protect_from_forgery except: :request_post

  UNDETERMINED_IP = '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>'

  rescue_from ApiClient::Error do |exception|
    logger.error(exception)
    render "errors/something_went_wrong"
  end

  def request_post
    x_forwarded_for = headers.fetch("X-Forwarded-For", UNDETERMINED_IP)
    cookies_from_api = authn_request_proxy.proxy(params['SAMLRequest'], params['RelayState'], x_forwarded_for)
    cookies_hash = CookieFactory.new(Rails.configuration.x.cookies.secure).create(cookies_from_api)
    cookies_hash.each { |name, value| cookies[name] = value }
    redirect_to '/start'
  end

private

  def authn_request_proxy
    AUTHN_REQUEST_PROXY
  end
end
