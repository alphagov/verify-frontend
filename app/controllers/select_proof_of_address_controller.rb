class SelectProofOfAddressController < ApplicationController
  def index
    @form = SelectProofOfAddressForm.new({})
    render :select_proof_of_address
  end

  def no_documents
    report_to_analytics('No Proof of Address Link Next')
    selected_answer_store.store_selected_answers('address_proof', 'uk_bank_account_details' => false, 'debit_card' => false, 'credit_card' => false)
    redirect_based_on_evidence
  end

  def select_proof
    @form = SelectProofOfAddressForm.new(params['select_proof_of_address_form'] || {})
    if @form.valid?
      report_to_analytics('Proof of Address Next')
      selected_answer_store.store_selected_answers('address_proof', @form.selected_answers)
      redirect_based_on_evidence
    else
      flash.now[:errors] = @form.errors.full_messages.join(', ')
      render :select_proof_of_address
    end
  end

private

  def redirect_based_on_evidence
    idps_available = IDP_ELIGIBILITY_CHECKER_B.any?(selected_evidence_assuming_phones, current_identity_providers)
    redirect_to idps_available ? select_phone_path : no_idps_available_path
  end

  def selected_evidence_assuming_phones
    (selected_evidence + [:mobile_phone, :smart_phone, :landline]).uniq
  end
end
