class SelectDocumentsController < ApplicationController
  def index
    reported_alternative = Cookies.parse_json(cookies[CookieNames::AB_TEST])['split_questions']
    AbTest.report('split_questions', reported_alternative, current_transaction_simple_id, request)
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
        # report_to_analytics('Select Documents Next')
        selected_answer_store.store_selected_answers('documents', @form.selected_answers)
        redirect_to select_phone_path
      end
    else
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

  def documents_eligibility_checker
    DOCUMENTS_ELIGIBILITY_CHECKER
  end

private
  def alternative_name_split_questions
    ab_test_cookie = Cookies.parse_json(cookies[CookieNames::AB_TEST])['split_questions']
    if AB_TESTS['split_questions']
      AB_TESTS['split_questions'].alternative_name(ab_test_cookie)
    else
      'default'
    end
  end

  def is_in_b_group?
    alternative_name_split_questions == 'split_questions_variant'
  end
end
