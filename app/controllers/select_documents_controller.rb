class SelectDocumentsController < ApplicationController
  def index
    @form = SelectDocumentsForm.new({})
  end

  def select_documents
    @form = SelectDocumentsForm.new(params[:select_documents_form])
    if @form.valid?
      if idp_eligibility_checker.any_for_documents?(@form)
        redirect_to select_phone_path
      else
        redirect_to unlikely_to_verify_path
      end
    else
      flash.now[:errors] = @form.errors.full_messages.join(', ')
      render :index
    end
  end

private

  def idp_eligibility_checker
    IdpEligibility::Checker.new
  end
end
