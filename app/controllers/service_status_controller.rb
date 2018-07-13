class ServiceStatusController < ApplicationController
  skip_before_action :update_translations
  skip_before_action :validate_session
  skip_before_action :set_piwik_custom_variables

  def index
    if ServiceStatus.unavailable?
      head 503
    else
      head 200
    end
  end
end
