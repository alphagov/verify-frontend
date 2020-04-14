class ErrorsController < ApplicationController
  skip_before_action :validate_session
  skip_before_action :set_piwik_custom_variables

  def page_not_found
    respond_to do |format|
      format.html { render "404", status: 404 }
      format.all { head 404 }
    end
  end
end
