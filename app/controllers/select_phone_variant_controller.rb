class SelectPhoneVariantController < ConfigurableJourneyController
  def index
    @form = SelectPhoneVariantForm.new({})
  end

  def select_phone
    @form = SelectPhoneVariantForm.new(params['select_phone_variant_form'] || {})

    session[:reluctant_mob_installation] = @form.smart_phone == 'reluctant_yes'

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
end
