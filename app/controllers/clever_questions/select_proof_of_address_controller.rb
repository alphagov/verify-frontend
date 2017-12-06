class CleverQuestions::SelectProofOfAddressController < ApplicationController
  def index
    @form = CleverQuestions::SelectProofOfAddressForm.new({})
    render :select_proof_of_address
  end

  def select_proof
    @form = CleverQuestions::SelectProofOfAddressForm.new(params['select_proof_of_address_form'] || {})
    if @form.valid?
      redirect_to select_phone_path
    else
      flash.now[:errors] = @form.errors.full_messages.join(', ')
      render :select_proof_of_address
    end
  end
end
