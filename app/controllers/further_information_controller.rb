class FurtherInformationController < ApplicationController
  def index
    @attribute = FURTHER_INFORMATION_SERVICE.fetch(cookies)
    @form = CycleThreeForm.new({})
    @transaction_name = current_transaction.name
  end

  def submit
    form = CycleThreeForm.new(params['cycle_three_form'])
    attribute = FURTHER_INFORMATION_SERVICE.fetch(cookies)
    FURTHER_INFORMATION_SERVICE.submit(cookies, form.cycle_three_data)
    FEDERATION_REPORTER.report_cycle_three(request, attribute.simple_id)
    redirect_to response_processing_path
  end

  def cancel
    FURTHER_INFORMATION_SERVICE.cancel(cookies)
    FEDERATION_REPORTER.report_cycle_three_cancel(current_transaction_simple_id, request)
    redirect_to redirect_to_service_start_again_path
  end
end
