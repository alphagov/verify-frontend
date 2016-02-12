class SamlController < ApplicationController
  protect_from_forgery except: :request_post

  rescue_from ApiClient::Error do |exception|
    logger.error(exception)
    render "errors/something_went_wrong"
  end

  def request_post
    cookies_from_api = authn_request_proxy.proxy(params['SAMLRequest'], params['RelayState'])
    cookies_from_api.each { |name, value| cookies.permanent[name] = value}
    redirect_to '/start'
  end

private

  def authn_request_proxy
    AUTHN_REQUEST_PROXY
  end
end
