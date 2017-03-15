class SelectDocumentsController < ConfigurableJourneyController
  def index
    @form = SelectDocumentsForm.new({})
  end

  def select_documents
    @form = SelectDocumentsForm.new(params['select_documents_form'] || {})
    if @form.valid?
      report_to_analytics('Select Documents Next')
      selected_answer_store.store_selected_answers('documents', @form.selected_answers)
      idps_available = DOCUMENTS_ELIGIBILITY_CHECKER.any?(selected_evidence, current_identity_providers)
      redirect_to next_page(idps_available ? [:idps_available] : [:no_idps_available])
    else
      flash.now[:errors] = @form.errors.full_messages.join(', ')
      render :index
    end
  end

  def unlikely_to_verify
    @selected_evidence = selected_evidence
    @current_identity_providers = current_identity_providers
    @other_ways_description = current_transaction.other_ways_description
    @other_ways_text = current_transaction.other_ways_text
  end

  def documents_eligibility_checker
    DOCUMENTS_ELIGIBILITY_CHECKER
  end
end
