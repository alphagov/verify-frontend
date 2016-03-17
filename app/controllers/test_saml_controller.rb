class TestSamlController < ApplicationController
  skip_before_action :validate_cookies
  layout 'test'

  def index
    render 'index'
  end

  def idp_request
    @saml_request = params['SAMLRequest']
    @relay_state = params['RelayState']
    @registration = params['registration']
    render 'idp_request'
  end
end
