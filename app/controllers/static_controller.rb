class StaticController < ApplicationController
  skip_before_action :validate_cookies
end
