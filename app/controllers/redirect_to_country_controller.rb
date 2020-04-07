require "partials/eidas_validation_partial_controller"

class RedirectToCountryController < ApplicationController
  include EidasValidationPartialController
  before_action :ensure_session_eidas_supported

  def choose_a_country_submit
    decorated_country = decorated_country(params[:country])
    if decorated_country.viewable?
      select_country(decorated_country)
      render :index
    else
      something_went_wrong("Couldn't redirect to country with id #{params[:country]}")
    end
  end

  def choose_a_country_submit_ajax
    decorated_country = decorated_country(params[:country])
    if decorated_country.viewable?
      select_country(decorated_country)
      render json: @country_request
    else
      head :bad_request
    end
  end

private

  def decorated_country(country_simple_id)
    countries = POLICY_PROXY.get_countries(session[:verify_session_id]).countries.select do |country|
      country.simple_id == country_simple_id
    end

    return Display::NotViewableCountry.new unless countries.count == 1

    COUNTRY_DISPLAY_DECORATOR.decorate(countries.first)
  end

  def select_country(decorated_country)
    store_selected_country_for_session(decorated_country.country)
    POLICY_PROXY.select_a_country(session[:verify_session_id], decorated_country.simple_id)

    saml_message = SAML_PROXY_API.authn_request(session[:verify_session_id])
    @country_request = CountryRequest.new(saml_message)
  end
end
