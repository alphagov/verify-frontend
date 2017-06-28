class SelectProofOfAddressForm
  include ActiveModel::Model

  attr_reader :bank_account, :debit_card, :credit_card

  def initialize(params)
    @bank_account = params[:bank_account]
    @debit_card = params[:debit_card]
    @credit_card = params[:credit_card]
  end

  def selected_answers
    answers = {}
    IdpEligibility::Evidence::ADDRESS_DOCUMENT_ATTRIBUTES.each do |attr|
      result = public_send(attr)
      if %w(true false).include?(result)
        answers[attr] = result == 'true'
      end
    end
    answers
  end
end