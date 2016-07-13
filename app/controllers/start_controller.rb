class StartController < ApplicationController
  layout 'slides'

  def index
    render 'index'
  end

  def request_post
    if params['start_form'].present?
      params['selection'] = params['start_form']['selection']
    end
    if params['selection'].blank?
      @error_message = 'hub.start.error_message'
      render 'index'
    elsif params['selection'] == 'true'
      redirect_to about_path(locale: I18n.locale), status: :see_other
    else
      redirect_to sign_in_path(locale: I18n.locale), status: :see_other
    end
  end
end
