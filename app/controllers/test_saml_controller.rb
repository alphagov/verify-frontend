class TestSamlController < ApplicationController
  skip_before_action :validate_cookies

  def index
    render 'index'
  end

  def idp_request
    render inline: "AUTHN REQUEST RECEIVED"
  end
end
