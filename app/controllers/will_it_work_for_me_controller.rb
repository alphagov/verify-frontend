class WillItWorkForMeController < ApplicationController
  def index
    @form = WillItWorkForMeForm.new({})
  end

  def will_it_work_for_me
    @form = WillItWorkForMeForm.new(params[:will_it_work_for_me_form] || {})
    if @form.valid?
      uri = URI(redirect_path)
      uri.query = request.query_string
      redirect_to uri.to_s
    else
      flash.now[:errors] = @form.errors.full_messages.join(', ')
      render :index
    end
  end

private

  def redirect_path
    if @form.resident_last_12_months?
      @form.above_age_threshold? ? choose_a_certified_company_path : why_might_this_not_work_for_me_path
    elsif @form.address_but_not_resident?
      may_not_work_if_you_live_overseas_path
    elsif @form.no_uk_address?
      will_not_work_without_uk_address_path
    else
      why_might_this_not_work_for_me_path
    end
  end
end
