class SelectPhoneController < ApplicationController
  def index
    @form = SelectPhoneForm.new({})
  end

  def select_phone
    @form = SelectPhoneForm.new(params[:select_phone_form] || {})
    unless @form.valid?
      flash.now[:errors] = @form.errors.full_messages.join(', ')
    end
    render :index
  end
end
