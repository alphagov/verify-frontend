require 'ostruct'

class FurtherInformationController < ApplicationController
  def index
    @attribute = further_information_service.fetch(cookies)
  end

  def further_information_service
    FurtherInformationService.new(SESSION_PROXY, CYCLE_THREE_DISPLAY_REPOSITORY)
  end
end
