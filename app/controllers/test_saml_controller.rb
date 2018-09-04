class TestSamlController < ApplicationController
  skip_before_action :validate_session
  skip_before_action :set_piwik_custom_variables
  skip_after_action :store_locale_in_cookie
  layout 'test'

  def index
    render 'index'
  end

  def idp_request
    @saml_request = params['SAMLRequest']
    @relay_state = params['RelayState']
    @registration = params['registration']
    @language_hint = params['language']
    @single_idp = params['singleIdpJourneyIdentifier']

    # There must be a neater way of getting the `hint` parameters out
    blah = request.body_stream.read
    @hints = blah.split('&').select { |x| x.starts_with? 'hint' }.map { |x| x.split('=')[1] }.join(', ')

    render 'idp_request'
  end
end
