class FurtherInformationController < ApplicationController
  def index
    @cycle_three_attribute = FURTHER_INFORMATION_SERVICE.get_attribute_for_session(cookies).new({})
    @transaction_name = current_transaction.name
  end

  def submit
    cycle_three_attribute_class = FURTHER_INFORMATION_SERVICE.get_attribute_for_session(cookies)
    @cycle_three_attribute = cycle_three_attribute_class.new(params['cycle_three_attribute'])
    if @cycle_three_attribute.valid?
      FURTHER_INFORMATION_SERVICE.submit(cookies, @cycle_three_attribute.sanitised_cycle_three_data)
      FEDERATION_REPORTER.report_cycle_three(request, @cycle_three_attribute.simple_id)
      redirect_to response_processing_path
    else
      @transaction_name = current_transaction.name
      render 'index'
    end
  end

  def cancel
    FURTHER_INFORMATION_SERVICE.cancel(cookies)
    FEDERATION_REPORTER.report_cycle_three_cancel(current_transaction, request)
    redirect_to redirect_to_service_start_again_path
  end

  def submit_null_attribute
    cycle_three_attribute_class = FURTHER_INFORMATION_SERVICE.get_attribute_for_session(cookies)
    if cycle_three_attribute_class.allows_nullable?
      FURTHER_INFORMATION_SERVICE.submit(cookies, '')
      FEDERATION_REPORTER.report_cycle_three(request, cycle_three_attribute_class.simple_id)
      redirect_to response_processing_path
    else
      something_went_wrong('Unexpected submission to Cycle3 Null Attribute endpoint', :forbidden)
    end
  end
end
