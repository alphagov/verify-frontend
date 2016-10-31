class SelectDocumentsController < ApplicationController
  def index
    @form = SelectDocumentsForm.new({}, form_attributes)
    @is_in_b_group = is_in_b_group?
  end

  def select_documents
    @form = SelectDocumentsForm.new(params['select_documents_form'] || {}, form_attributes)
    if @form.valid?
      report_to_analytics('Select Documents Next')
      selected_answer_store.store_selected_answers('documents', @form.selected_answers)
      if documents_eligibility_checker.any?(selected_evidence, current_identity_providers)
        redirect_to select_phone_path
      else
        redirect_to unlikely_to_verify_path
      end
    else
      @is_in_b_group = is_in_b_group?
      flash.now[:errors] = @form.errors.full_messages.join(', ')
      render :index
    end
  end

  def unlikely_to_verify
    @selected_evidence = selected_evidence
    @current_identity_providers = current_identity_providers
    @things = [CONFIG.rules_directory, CONFIG.rules_directory_b]
    @other_ways_description = current_transaction.other_ways_description
    @other_ways_text = current_transaction.other_ways_text
  end

  def documents_eligibility_checker
    if is_in_b_group?
      DOCUMENTS_ELIGIBILITY_CHECKER_B
    else
      DOCUMENTS_ELIGIBILITY_CHECKER
    end
  end

  def form_attributes
    if is_in_b_group?
      [:passport, :driving_licence, :ni_driving_licence, :non_uk_id_document, :uk_bank_account_details, :debit_card, :credit_card]
    else
      [:passport, :driving_licence, :ni_driving_licence, :non_uk_id_document]
    end
  end
end
