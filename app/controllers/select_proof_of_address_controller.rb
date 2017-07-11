class SelectProofOfAddressController < ApplicationController
  def index
    @form = SelectProofOfAddressForm.new({})
    render :select_proof_of_address
  end

  def select_proof
    @form = SelectProofOfAddressForm.new(params['select_proof_of_address_form'] || {})
    if @form.valid?
      selected_answer_store.store_selected_answers('address_proof', @form.selected_answers)
      idps_available = IDP_ELIGIBILITY_CHECKER_B.any?(selected_evidence, current_identity_providers)
      redirect_to idps_available ? select_phone_path : no_idps_available_path
    else
      flash.now[:errors] = @form.errors.full_messages.join(', ')
      render :select_proof_of_address
    end
  end
end
