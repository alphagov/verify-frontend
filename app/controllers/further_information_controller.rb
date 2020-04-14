class FurtherInformationController < ApplicationController
  def index
    @seconds_to_timeout = get_seconds_to_timeout
    return redirect_to further_information_timeout_path if expired?

    session_id = session[:verify_session_id]
    @cycle_three_attribute = FURTHER_INFORMATION_SERVICE.get_attribute_for_session(session_id).new({})
    @transaction_name = current_transaction.name
    @idp_name = selected_provider.display_name
  end

  def submit
    return redirect_to further_information_timeout_path if expired?

    session_id = session[:verify_session_id]
    cycle_three_attribute_class = FURTHER_INFORMATION_SERVICE.get_attribute_for_session(session_id)
    @cycle_three_attribute = cycle_three_attribute_class.new(params["cycle_three_attribute"])
    if @cycle_three_attribute.valid?
      FURTHER_INFORMATION_SERVICE.submit(session_id, @cycle_three_attribute.sanitised_cycle_three_data)
      FEDERATION_REPORTER.report_cycle_three(current_transaction, request, @cycle_three_attribute.simple_id)
      redirect_to response_processing_path
    else
      @seconds_to_timeout = get_seconds_to_timeout
      @transaction_name = current_transaction.name
      flash.now[:errors] = @cycle_three_attribute.errors.full_messages.join(", ")
      render "index"
    end
  end

  def timeout
    @idp_name = selected_provider.display_name
    @transaction_name = current_transaction.name
    @journey_hint = user_journey_type?(JourneyType::VERIFY) ? "submission_confirmation" : "eidas_sign_in"
  end

  def cancel
    session_id = session[:verify_session_id]
    FURTHER_INFORMATION_SERVICE.cancel(session_id)
    FEDERATION_REPORTER.report_cycle_three_cancel(current_transaction, request)
    redirect_to redirect_to_service_start_again_path
  end

  def submit_null_attribute
    session_id = session[:verify_session_id]
    cycle_three_attribute_class = FURTHER_INFORMATION_SERVICE.get_attribute_for_session(session_id)
    if cycle_three_attribute_class.allows_nullable?
      FURTHER_INFORMATION_SERVICE.submit(session_id, "")
      FEDERATION_REPORTER.report_cycle_three(current_transaction, request, cycle_three_attribute_class.simple_id)
      redirect_to response_processing_path
    else
      something_went_wrong("Unexpected submission to Cycle3 Null Attribute endpoint", :forbidden)
    end
  end

private

  def expired?
    !session[:assertion_expiry].nil? && Time.parse(session[:assertion_expiry]) <= Time.now.utc
  end

  def get_seconds_to_timeout
    (Time.parse(session[:assertion_expiry]) - Time.now.utc).to_i unless session[:assertion_expiry].nil?
  end
end
