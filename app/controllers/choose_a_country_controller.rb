require 'partials/eidas_validation_partial_controller'

class ChooseACountryController < ApplicationController
  include EidasValidationPartialController
  before_action :ensure_session_eidas_supported

  def choose_a_country
    setup_countries(session[:verify_session_id])
  end

  def choose_a_country_submit
    session_id = session[:verify_session_id]
    setup_countries(session_id)

    country = params[:country]
    if country.empty?
      flash.now[:errors] = true
      render 'choose_a_country'
      return
    end

    POLICY_PROXY.select_a_country(session_id, country)

    redirect_to '/redirect-to-country'
  end

private

  def setup_countries(session_id)
    countries_map = POLICY_PROXY.get_countries(session_id)
    @countries = COUNTRY_DISPLAY_DECORATOR.decorate_collection(countries_map.countries)
  end
end
