class SelectDocumentsController < ApplicationController
  def index
    @form = SelectDocumentsForm.new({})
    @alternative_name = show_ab_test_view
  end

  def show_ab_test_view
    ab_test_cookie = Cookies.parse_json(cookies[CookieNames::AB_TEST])['select_documents']
    AB_TESTS['select_documents'] ? AB_TESTS['select_documents'].alternative_name(ab_test_cookie) : 'default'
  end

  def select_documents
    @form = SelectDocumentsForm.new(params['select_documents_form'] || {})
    if @form.valid?
      report_to_analytics('Select Documents Next')
      selected_answer_store.store_selected_answers('documents', @form.selected_answers)
      if documents_eligibility_checker.any?(selected_evidence, current_identity_providers)
        redirect_to select_phone_path
      else
        redirect_to unlikely_to_verify_path
      end
    else
      @alternative_name = show_ab_test_view
      flash.now[:errors] = @form.errors.full_messages.join(', ')
      render :index
    end
  end

  def unlikely_to_verify
    @other_ways_description = current_transaction.other_ways_description
    @other_ways_text = current_transaction.other_ways_text
  end

  def documents_eligibility_checker
    DOCUMENTS_ELIGIBILITY_CHECKER
  end
end
