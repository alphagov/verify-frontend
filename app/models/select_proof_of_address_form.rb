class SelectProofOfAddressForm
  include ActiveModel::Model

  attr_reader :bank_account, :debit_card, :credit_card

  def initialize(params)
    @bank_account = params[:bank_account]
    @debit_card = params[:debit_card]
    @credit_card = params[:credit_card]
  end

  def selected_answers
    filter_invalid_attributes = -> (attr) { %w(true false).include?(public_send(attr)) }
    attribute_to_value = -> (attr) { [attr, public_send(attr) == 'true'] }

    IdpEligibility::Evidence::ADDRESS_DOCUMENT_ATTRIBUTES
        .select(&filter_invalid_attributes)
        .map(&attribute_to_value)
        .to_h
  end
end
