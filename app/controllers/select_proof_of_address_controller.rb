class SelectProofOfAddressController < ApplicationController
  def index
    @form = SelectProofOfAddressForm.new({})
    render :select_proof_of_address
  end

  def select_proof
    @form = SelectProofOfAddressForm.new(params['select_proof_of_address_form'] || {})
    if @form.valid?
      selected_answer_store.store_selected_answers('address_proof', @form.selected_answers)
      redirect_to select_phone_path
    else
      flash.now[:errors] = @form.errors.full_messages.join(', ')
      render :select_proof_of_address
    end
  end
end
