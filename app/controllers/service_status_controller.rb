class ServiceStatusController < ApplicationController
  skip_before_action :validate_session

  def index
    if ServiceStatus.unavailable?
      head 503
    else
      head 200
    end
  end
end
