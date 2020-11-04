require "partials/eidas_validation_partial_controller"

class ChooseACountryController < ApplicationController
  include EidasValidationPartialController
  before_action :ensure_session_eidas_supported
  before_action :setup_countries

  def choose_a_country
    restart_journey if identity_provider_selected? && !user_journey_type?(JourneyType::EIDAS)
    @other_ways_description = current_transaction.other_ways_description
  end

  def eu_exit
    render :eu_exit
  end

private

  def setup_countries
    logger.info("phil test2 before_eu_exit")
    logger.info(session[:before_eu_exit])
    countries_map = POLICY_PROXY.get_countries(session[:verify_session_id])
    @countries = COUNTRY_DISPLAY_DECORATOR.decorate_collection(countries_map.countries)
    @before_eu_exit = session[:before_eu_exit]
  end
end
