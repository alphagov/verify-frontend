class OtherIdentityDocumentsVariantController < ApplicationController
  def index
    @form = OtherIdentityDocumentsForm.new({})
  end

  def select_other_documents
    @form = OtherIdentityDocumentsForm.new(params['other_identity_documents_form'] || {})
    if @form.valid?
      selected_answer_store.store_selected_answers('other_documents', @form.selected_answers)
      redirect_to select_phone_path
    else
      flash.now[:errors] = @form.errors.full_messages.join(', ')
      render :index
    end
  end
end
