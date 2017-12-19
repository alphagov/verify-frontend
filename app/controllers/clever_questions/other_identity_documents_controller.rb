class CleverQuestions::OtherIdentityDocumentsController < ApplicationController
  def index
    @form = CleverQuestions::OtherIdentityDocumentsForm.new({})
  end

  def select_other_documents
    @form = CleverQuestions::OtherIdentityDocumentsForm.new(params['other_identity_documents_form'] || {})
    if @form.valid?
      report_to_analytics('Other Documents Next')
      selected_answer_store.store_selected_answers('other_documents', @form.selected_answers)
      redirect_to select_proof_of_address_path
    else
      flash.now[:errors] = @form.errors.full_messages.join(', ')
      render :index
    end
  end
end
