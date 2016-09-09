class ErrorsController < ApplicationController
  skip_before_action :validate_session
  def page_not_found
    respond_to do |format|
      format.html { render '404', status: 404 }
      format.all { redirect_to '/404' }
    end
  end
end
