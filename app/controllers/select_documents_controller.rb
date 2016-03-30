class SelectDocumentsController < ApplicationController
  def index
    @form = SelectDocumentsForm.new({})
  end

  def select_documents
    @form = SelectDocumentsForm.new(params[:select_documents_form])
    if @form.valid?
      if IDP_ELIGIBILITY_CHECKER.any_for_documents?(@form.selected_evidence)
        redirect_to select_phone_path
      else
        redirect_to unlikely_to_verify_path
      end
    else
      flash.now[:errors] = @form.errors.full_messages.join(', ')
      render :index
    end
  end
end
