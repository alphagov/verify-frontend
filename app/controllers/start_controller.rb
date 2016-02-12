class StartController < ApplicationController
  layout 'start'
  def index
    validation = cookie_validator.validate(cookies)
    if validation.ok?
      render "index"
    else
      render_error(validation)
    end
  end

  def request_post
    if params['selection'] == 'true'
      redirect_to "/about", status: :see_other
    else
      redirect_to "/sign-in", status: :see_other
    end
  end

private

  def render_error(validation)
    logger.info(validation.message)
    render "errors/#{validation.type}", status: validation.status
  end

  def cookie_validator
    COOKIE_VALIDATOR
  end
end
