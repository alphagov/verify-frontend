class SelectDocumentsController < ApplicationController
  def index
    @form = SelectDocumentsForm.new({})
  end

  def select_documents
    @form = SelectDocumentsForm.new(params[:select_documents_form])
    if @form.valid?
      redirect_to select_phone_path
    else
      flash.now[:errors] = @form.errors.full_messages.join(', ')
      render :index
    end
  end
end
