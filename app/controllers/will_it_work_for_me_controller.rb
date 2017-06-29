class WillItWorkForMeController < ApplicationController
  def index
    @form = WillItWorkForMeForm.new({})
  end

  def will_it_work_for_me
    @form = WillItWorkForMeForm.new(params['will_it_work_for_me_form'] || {})
    if @form.valid?
      report_to_analytics('Can I be Verified Next')
      redirect_to next_page
    else
      flash.now[:errors] = @form.errors.full_messages.join(', ')
      render :index
    end
  end

  def why_might_this_not_work_for_me
    @other_ways_description = current_transaction.other_ways_description
    @other_ways_text = current_transaction.other_ways_text
  end

  def may_not_work_if_you_live_overseas
    @other_ways_description = current_transaction.other_ways_description
    @other_ways_text = current_transaction.other_ways_text
  end

  def will_not_work_without_uk_address
    @other_ways_description = current_transaction.other_ways_description
    @other_ways_text = current_transaction.other_ways_text
  end

private

  def next_page
    case [@form.above_age_threshold?, @form.resident_last_12_months?, @form.not_resident_reason]
    when [true, true, nil]
      select_documents_path
    when [true, false, 'AddressButNotResident']
      may_not_work_if_you_live_overseas_path
    when [true, false, 'NoAddress']
      will_not_work_without_uk_address_path
    else
      why_might_this_not_work_for_me_path
    end
  end
end
