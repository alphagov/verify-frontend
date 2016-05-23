class SelectPhoneController < ApplicationController
  def index
    @form = SelectPhoneForm.new({})
  end

  def select_phone
    @form = SelectPhoneForm.new(params['select_phone_form'] || {})
    if @form.valid?
      report_to_analytics('Phone Next')
      store_selected_evidence('phone', @form.selected_evidence)
      if idp_eligibility_checker.any?(selected_evidence_values, available_idps)
        redirect_to will_it_work_for_me_path
      else
        redirect_to no_mobile_phone_path
      end
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

  def available_idps
    SESSION_PROXY.identity_providers(cookies)
  end

  def idp_eligibility_checker
    IDP_ELIGIBILITY_CHECKER
  end
end
