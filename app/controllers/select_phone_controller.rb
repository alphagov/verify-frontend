class SelectPhoneController < ApplicationController
  def index
    @form = SelectPhoneForm.new({})
  end

  def select_phone
    @form = SelectPhoneForm.new(params[:select_phone_form] || {})
    if @form.valid?
      redirect_to will_it_work_for_me_path
    else
      flash.now[:errors] = @form.errors.full_messages.join(', ')
      render :index
    end
  end
end
