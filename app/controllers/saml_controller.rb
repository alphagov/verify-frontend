class SamlController < ApplicationController
  rescue_from ApiClient::Error do |exception|
    logger.error(exception)
    render "errors/something_went_wrong"
  end

  def request_post
    cookies_from_api = AuthnRequestProxy.new(ApiClient.new("http://localhost:50190")).proxy(params['SAMLRequest'], params['RelayState'])
    cookies_from_api.each { |name, value| cookies.permanent[name] = value}
    redirect_to '/start'
  end
end
