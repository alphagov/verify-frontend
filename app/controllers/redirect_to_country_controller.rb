require 'partials/eidas_validation_partial_controller'

class RedirectToCountryController < ApplicationController
  include EidasValidationPartialController
  before_action :ensure_session_eidas_supported

  def choose_a_country_submit
    country = decorated_country(params[:country])
    session[:selected_country] = country.country
    if country.viewable?
      select_country(country)
      render :index
    else
      something_went_wrong("Couldn't redirect to country with id #{params[:country]}")
    end
  end

  def choose_a_country_submit_ajax
    country = decorated_country(params[:country])
    session[:selected_country] = country.country
    if country.viewable?
      select_country(country)
      render json: @country_request
    else
      render status: :bad_request
    end
  end

private

  def decorated_country(country_simple_id)
    countries = POLICY_PROXY.get_countries(session[:verify_session_id]).countries.select do |country|
      country.simple_id == country_simple_id
    end

    return Display::NotViewableCountry.new unless countries.count == 1

    @decorated_country ||= COUNTRY_DISPLAY_DECORATOR.decorate(countries.first)
  end

  def select_country(country)
    POLICY_PROXY.select_a_country(session[:verify_session_id], country.simple_id)

    saml_message = SAML_PROXY_API.authn_request(session[:verify_session_id])
    @country_request = CountryRequest.new(saml_message)
  end
end
