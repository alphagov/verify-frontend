class OtherIdentityDocumentsVariantController < ApplicationController
  def index
    @form = OtherIdentityDocumentsVariantForm.new({})
  end

  def select_other_documents
    @form = OtherIdentityDocumentsVariantForm.new(params['other_identity_documents_variant_form'] || {})
    if @form.valid?
      selected_answer_store.store_selected_answers('other_documents', @form.selected_answers)
      redirect_to choose_a_certified_company_path
    else
      flash.now[:errors] = @form.errors.full_messages.join(', ')
      render :index
    end
  end
end
