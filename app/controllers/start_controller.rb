class StartController < ApplicationController
  layout 'start'
  def index
    validation = CookieValidator.new.validate(cookies)
    if validation.ok?
      render "index"
    else
      render_error(validation)
    end
  end

  def render_error(validation)
    logger.info(validation.message)
    render "errors/#{validation.type}", status: validation.status
  end
end
