class StartController < ApplicationController
  layout 'start'

  def index
    render 'index'
  end

  def request_post
    if params['selection'].blank?
      @error_message = 'hub.start.error_message'
      render "index"
    elsif params['selection'] == 'true'
      redirect_to about_path(locale: I18n.locale), status: :see_other
    else
      redirect_to sign_in_path(locale: I18n.locale), status: :see_other
    end
  end
end
