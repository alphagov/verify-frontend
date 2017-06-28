class SelectProofOfAddressController < ConfigurableJourneyController

  def index
    @form = SelectProofOfAddressForm.new({})

    render :select_proof_of_address
  end
end