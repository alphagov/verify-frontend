class StaticController < ApplicationController
  skip_before_action :validate_cookies

  def cookies
  end

  def privacy_notice
  end

  def humanstxt
    render 'static/humans.txt.erb'
  end
end
