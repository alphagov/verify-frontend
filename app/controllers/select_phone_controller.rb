class SelectPhoneController < ConfigurableJourneyController
  def index
    reported_alternative = Cookies.parse_json(cookies[CookieNames::AB_TEST])['reluctant_mob_app']
    AbTest.report('reluctant_mob_app',
                  reported_alternative,
                  current_transaction_simple_id, request)
    @is_in_b_group = is_in_b_group?

    @form = SelectPhoneForm.new({})
  end

  def select_phone
    @form = SelectPhoneForm.new(params['select_phone_form'] || {})
    if @form.valid?
      report_to_analytics('Phone Next')
      selected_answer_store.store_selected_answers('phone', @form.selected_answers)
      idps_available = IDP_ELIGIBILITY_CHECKER.any?(selected_evidence, current_identity_providers)
      redirect_to next_page(idps_available ? [:idps_available] : [:no_idps_available])
    else
      flash.now[:errors] = @form.errors.full_messages.join(', ')
      render :index
    end
  end

  def no_mobile_phone
    @other_ways_description = current_transaction.other_ways_description
    @other_ways_text = current_transaction.other_ways_text
  end

private

  def is_in_b_group?
    ab_test_cookie = Cookies.parse_json(cookies[CookieNames::AB_TEST])['reluctant_mob_app']
    if AB_TESTS['reluctant_mob_app']
      AB_TESTS['reluctant_mob_app'].alternative_name(ab_test_cookie) == 'with_installation_warning'
    else
      false
    end
  end

end
