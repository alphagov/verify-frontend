require 'partials/viewable_idp_partial_controller'

class SelectDocumentsVariantController < ApplicationController
  include ViewableIdpPartialController

  def index
    @form = SelectDocumentsForm.new({})
    render :index
  end

  def select_documents
    @form = SelectDocumentsForm.new(params['select_documents_form'] || {})
    if @form.valid?
      report_to_analytics('Select Documents Next')
      selected_answer_store.store_selected_answers('documents', @form.selected_answers)
      redirect_to @form.further_id_information_required? ? other_identity_documents_path : choose_a_certified_company_path
    else
      flash.now[:errors] = @form.errors.full_messages.join(', ')
      render :index
    end
  end

  def no_documents
    report_to_analytics('Select No Documents Link Next')
    selected_answer_store.store_selected_answers('documents', 'passport' => false, 'driving_licence' => false, 'ni_driving_licence' => false)
    redirect_to other_identity_documents_path
  end
end
