class WillItWorkForMeController < ApplicationController
  def index
    @form = WillItWorkForMeForm.new({})
  end

  def will_it_work_for_me
    @form = WillItWorkForMeForm.new(params[:will_it_work_for_me_form])
    if @form.resident_last_12_months?
      if @form.above_age_threshold?
        path_to_redirect = choose_a_certified_company_path
      else
        path_to_redirect = why_might_this_not_work_for_me_path
      end
    elsif @form.address_but_not_resident?
      path_to_redirect = may_not_work_if_you_live_overseas_path
    elsif @form.no_uk_address?
      path_to_redirect = will_not_work_without_uk_address_path
    else
      path_to_redirect = why_might_this_not_work_for_me_path
    end
    uri = URI(path_to_redirect)
    uri.query = request.query_string
    redirect_to uri.to_s
  end
end
