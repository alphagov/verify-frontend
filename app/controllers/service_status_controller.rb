class ServiceStatusController < ApplicationController
  skip_before_action :validate_cookies

  def index
    if ServiceStatus.unavailable?
      render nothing: true, status: 503
    else
      render nothing: true, status: 200
    end
  end
end
