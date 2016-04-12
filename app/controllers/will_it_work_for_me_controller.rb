class WillItWorkForMeController < ApplicationController
  def index
    @form = WillItWorkForMeForm.new({})
  end

  def will_it_work_for_me
    @form = WillItWorkForMeForm.new(params[:will_it_work_for_me_form])
    if @form.resident_last_12_months?
      redirect_to choose_a_certified_company_path
    elsif @form.address_but_not_resident?
      redirect_to may_not_work_if_you_live_overseas_path
    elsif @form.no_uk_address?
      redirect_to will_not_work_without_uk_address_path
    else
      redirect_to why_might_this_not_work_for_me_path
    end
  end
end
