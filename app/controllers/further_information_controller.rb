class FurtherInformationController < ApplicationController
  def index
    @attribute = FURTHER_INFORMATION_SERVICE.fetch(cookies)
    @form = CYCLE_THREE_FORMS.fetch(@attribute.simple_id).new({})
    @transaction_name = current_transaction.name
  end

  def submit
    @attribute = FURTHER_INFORMATION_SERVICE.fetch(cookies)
    form_class = CYCLE_THREE_FORMS.fetch(@attribute.simple_id)
    @form = form_class.new(params.fetch('cycle_three_form'))
    if @form.valid?
      FURTHER_INFORMATION_SERVICE.submit(cookies, @form.sanitised_cycle_three_data)
      FEDERATION_REPORTER.report_cycle_three(request, @attribute.simple_id)
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
    attribute = FURTHER_INFORMATION_SERVICE.fetch(cookies)
    form_class = CYCLE_THREE_FORMS.fetch(attribute.simple_id)

    if form_class.new({}).allows_nullable?
      FURTHER_INFORMATION_SERVICE.submit(cookies, '')
      FEDERATION_REPORTER.report_cycle_three(request, attribute.simple_id)
      redirect_to response_processing_path
    else
      something_went_wrong('Unexpected submission to Cycle3 Null Attribute endpoint', :forbidden)
    end
  end
end
