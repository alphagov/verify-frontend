class StartController < ApplicationController
  layout 'slides'

  def index
    @form = StartForm.new({})
  end

  def request_post
    @form = StartForm.new(params['start_form'] || {})
    if @form.valid?
      if @form.registration?
        redirect_to about_path, status: :see_other
      else
        redirect_to sign_in_path, status: :see_other
      end
    else
      flash.now[:errors] = @form.errors.full_messages.join(', ')
      render :index
    end
  end
end
