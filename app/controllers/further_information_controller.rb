require 'ostruct'

class FurtherInformationController < ApplicationController
  def index
    @attribute = further_information_service.fetch(cookies)
    @form = CycleThreeForm.new
    @transaction_name = current_transaction.name
  end

  def further_information_service
    FurtherInformationService.new(SESSION_PROXY, CYCLE_THREE_DISPLAY_REPOSITORY)
  end
end
