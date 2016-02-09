class StartController < ApplicationController
  layout 'start'
  def index
    validation = CookieValidator.new.validate(cookies)
    if validation.ok?
      render "index"
    elsif validation.no_cookies?
      logger.info(validation.message)
      render "errors/no_cookies"
    else
      render "something_went_wrong"
    end
  end
end
