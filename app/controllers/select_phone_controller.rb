class SelectPhoneController < ApplicationController
  def index
    @form = SelectPhoneForm.new({})
  end

  def select_phone
    @form = SelectPhoneForm.new(params['select_phone_form'] || {})
    if @form.valid?
      ANALYTICS_REPORTER.report(request, 'Phone Next')
      store_selected_evidence(phone: @form.selected_evidence)
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

private

  def available_idps
    SESSION_PROXY.federation_info_for_session(cookies).idps
  end

  def idp_eligibility_checker
    IDP_ELIGIBILITY_CHECKER
  end
end
