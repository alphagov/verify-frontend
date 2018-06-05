require 'partials/eidas_validation_partial_controller'

class ChooseACountryController < ApplicationController
  include EidasValidationPartialController
  before_action :ensure_session_eidas_supported
  before_action :setup_countries

  def choose_a_country
    @other_ways_description = current_transaction.other_ways_description
  end

  def choose_a_country_submit
    country = params[:country]
    if country.nil? || country.empty?
      flash.now[:errors] = true
      render 'choose_a_country'
      return
    end

    POLICY_PROXY.select_a_country(session[:verify_session_id], country)

    redirect_to '/redirect-to-country'
  end

private

  def setup_countries
    countries_map = POLICY_PROXY.get_countries(session[:verify_session_id])
    scheme_map = EIDAS_SCHEME_DISPLAY_DECORATOR.decorate_collection(EIDAS_SCHEME_REPOSITORY.values).group_by(&:country_simple_id)
    @countries = COUNTRY_DISPLAY_DECORATOR.decorate_collection(countries_map.countries, scheme_map)
  end
end
