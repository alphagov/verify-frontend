class SelectPhoneController < ApplicationController
  def index
    @form = SelectPhoneForm.new
  end

  def select_phone
    @form = SelectPhoneForm.new
    render :index
  end
end
