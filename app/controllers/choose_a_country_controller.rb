require 'partials/eidas_validation_partial_controller'

class ChooseACountryController < ApplicationController
  include EidasValidationPartialController
  before_action :ensure_session_eidas_supported
  before_action :setup_countries

  def choose_a_country
    POLICY_PROXY.restart_journey(session[:verify_session_id]) if is_provider_type?(JourneyType::VERIFY)
    @other_ways_description = current_transaction.other_ways_description
  end

private

  def setup_countries
    countries_map = POLICY_PROXY.get_countries(session[:verify_session_id])
    @countries = COUNTRY_DISPLAY_DECORATOR.decorate_collection(countries_map.countries)
  end
end
