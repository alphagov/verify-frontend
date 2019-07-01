class ChooseACountryController < ApplicationController
  include EidasValidation
  before_action :ensure_session_eidas_supported
  before_action :setup_countries

  def choose_a_country
    restart_journey if identity_provider_selected? && !user_journey_type?(JourneyType::EIDAS)
    @other_ways_description = current_transaction.other_ways_description
  end

private

  def setup_countries
    countries_map = POLICY_PROXY.get_countries(session[:verify_session_id])
    @countries = COUNTRY_DISPLAY_DECORATOR.decorate_collection(countries_map.countries)
  end
end
