require 'partials/user_errors_partial_controller'

class InitiateJourneyController < ApplicationController
  include UserErrorsPartialController

  skip_before_action :validate_session
  skip_before_action :set_piwik_custom_variables

  def index
    reset_session
    simple_id_value = params.fetch('transaction_simple_id', nil)
    journey_hint_value = params.fetch('journey_hint', nil)

    transaction = CONFIG_PROXY.get_transaction_by_simple_id(simple_id_value)
    start_page = transaction.nil? ? nil : transaction.fetch('headlessStartpage') || transaction.fetch('serviceHomepage')

    if !start_page.nil?
      if valid_journey_hint?(journey_hint_value)
        session[:journey_hint] = journey_hint_value
        session[:journey_hint_rp] = simple_id_value
        return redirect_to merge_query_params(start_page, journey_hint_value)
      end
      logger.warn(invalid_parameters_message(simple_id_value, journey_hint_value))
      return redirect_to start_page
    end

    something_went_wrong(invalid_parameters_message(simple_id_value, journey_hint_value), 400)
  end

private

  def merge_query_params(uri, journey_hint)
    return uri if journey_hint.nil?

    uri = URI.parse(uri)
    query_array = URI.decode_www_form(String(uri.query)) << ["journey_hint", journey_hint]
    uri.query = URI.encode_www_form(query_array)
    uri.to_s
  end

  def valid_journey_hint?(journey_hint)
    return true if journey_hint&.starts_with?('idp_')

    [nil, 'uk_idp_start', 'registration', 'uk_idp_sign_in', 'eidas_sign_in', 'submission_confirmation'].include?(journey_hint)
  end

  def invalid_parameters_message(simple_id_value, journey_hint_value)
    "Invalid initiate-journey request - RP simple ID = '#{simple_id_value}', journey hint = '#{journey_hint_value}'"
  end
end
