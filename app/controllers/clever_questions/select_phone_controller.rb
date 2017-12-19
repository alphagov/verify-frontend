class CleverQuestions::SelectPhoneController < ApplicationController
  # TODO TT-1718: This before action can be removed after the release. Added here to ensure zero down time.
  before_action :set_device_type_evidence

  def index
    @form = CleverQuestions::SelectPhoneForm.new({})
  end

  def select_phone
    @form = CleverQuestions::SelectPhoneForm.new(params['select_phone_form'] || {})
    if @form.valid?
      report_to_analytics('Phone Next')
      FEDERATION_REPORTER.report_event(current_transaction, request, "Evidence", "Mobile phone", @form.mobile_phone)
      current_answers = selected_answer_store.selected_answers['phone'] || {}
      selected_answer_store.store_selected_answers('phone', current_answers.symbolize_keys.merge(@form.selected_answers))
      redirect_to confirming_it_is_you_path
    else
      flash.now[:errors] = @form.errors.full_messages.join(', ')
      render :index
    end
  end

  def no_mobile_phone
    @other_ways_description = current_transaction.other_ways_description
    @other_ways_text = current_transaction.other_ways_text
  end
end
