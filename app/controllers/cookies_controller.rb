class CookiesController < ApplicationController
  skip_before_action :validate_cookies

  def index
    render 'index'
  end
end
