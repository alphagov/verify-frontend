class SelectDocumentsController < ConfigurableJourneyController
  def index
    reported_alternative = Cookies.parse_json(cookies[CookieNames::AB_TEST])['split_questions_v2']
    AbTest.report('split_questions_v2', reported_alternative, current_transaction_simple_id, request)
    if is_in_b_group?
      @form = PhotoDocumentsForm.new({})
      render :photo_identity_documents
    end
    @form = SelectDocumentsForm.new({})
  end

  def select_documents
    if is_in_b_group?
      @form = PhotoDocumentsForm.new(params['photo_documents_form'] || {})
      if @form.valid?
        report_to_analytics('Select Documents Next')
        selected_answer_store.store_selected_answers('documents', @form.selected_answers)
        redirect_to next_page(@form.further_id_information_required? ? [:further_documents_needed] : [:no_further_documents_needed])
      else
        flash.now[:errors] = @form.errors.full_messages.join(', ')
        render :photo_identity_documents
      end
    else
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
  end

  def unlikely_to_verify
    @selected_evidence = selected_evidence
    @current_identity_providers = current_identity_providers
    @other_ways_description = current_transaction.other_ways_description
    @other_ways_text = current_transaction.other_ways_text
  end

private

  def alternative_name_split_questions
    ab_test_cookie = Cookies.parse_json(cookies[CookieNames::AB_TEST])['split_questions_v2']
    if AB_TESTS['split_questions_v2']
      AB_TESTS['split_questions_v2'].alternative_name(ab_test_cookie)
    else
      'default'
    end
  end

  def is_in_b_group?
    alternative_name_split_questions == 'split_questions_v2_variant'
  end
end
