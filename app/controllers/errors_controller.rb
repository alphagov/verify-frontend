class ErrorsController < ApplicationController
  skip_before_action :validate_cookies
  def page_not_found
    render '404', status: 404
  end
end
