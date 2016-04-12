class WillItWorkForMeController < ApplicationController
  def index
    @form = WillItWorkForMeForm.new({})
  end

  def will_it_work_for_me
    @form = WillItWorkForMeForm.new(params[:will_it_work_for_me_form])
    if @form.resident_last_12_months?
      redirect_to choose_a_certified_company_path
    else
      redirect_to why_might_this_not_work_for_me_path
    end
  end
end
