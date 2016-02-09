class StartController < ApplicationController
  layout 'start'
  def index
    validation = CookieValidator.new.validate(cookies)
    if validation.ok?
      render "index"
    elsif validation.no_cookies?
      logger.info(validation.message)
      render "errors/no_cookies"
    elsif validation.cookie_expired?
      logger.info(validation.message)
      render "errors/cookie_expired"
    else
      logger.info(validation.message)
      render "errors/something_went_wrong"
    end
  end
end
