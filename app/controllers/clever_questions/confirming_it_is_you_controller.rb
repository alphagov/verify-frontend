class CleverQuestions::ConfirmingItIsYouController < ApplicationController
  def index
    @form = CleverQuestions::ConfirmingItIsYouForm.new({})
    render 'clever_questions/confirming_it_is_you/confirming_it_is_you'
  end

  def select_answer
    @form = CleverQuestions::ConfirmingItIsYouForm.new(params['confirming_it_is_you_form'] || {})
    current_answers = selected_answer_store.selected_answers['phone'] || {}
    current_answers = adjust_evidence(current_answers.symbolize_keys)
    selected_answer_store.store_selected_answers('phone', current_answers.merge(@form.selected_answers))
    report_to_analytics('Smart Phone Next')
    idps_available = IDP_RECOMMENDATION_ENGINE.any?(current_identity_providers_for_loa, selected_evidence, current_transaction_simple_id)
    redirect_to idps_available ? choose_a_certified_company_path : no_mobile_phone_path
  end

private

  def adjust_evidence(current_answers)
    if !current_answers.empty? && current_answers[:mobile_phone] == false && @form.selected_answers[:smart_phone] == true
      {
        mobile_phone: true
      }
    else
      current_answers
    end
  end
end
