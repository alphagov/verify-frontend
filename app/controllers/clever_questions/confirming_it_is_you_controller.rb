class CleverQuestions::ConfirmingItIsYouController < ApplicationController
  def index
    @form = CleverQuestions::ConfirmingItIsYouForm.new({})
    render 'clever_questions/confirming_it_is_you/confirming_it_is_you'
  end

  def select_answer
    @form = CleverQuestions::ConfirmingItIsYouForm.new(params['confirming_it_is_you_form'] || {})
    current_answers = selected_answer_store.selected_answers['phone'] || {}
    if current_answers.length
      selected_answer_store.store_selected_answers('phone', current_answers.merge(@form.selected_answers))
    else
      selected_answer_store.store_selected_answers('phone', @form.selected_answers)
    end
    redirect_to proof_of_address_path
  end
end
