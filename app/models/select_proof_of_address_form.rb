class SelectProofOfAddressForm
  include ActiveModel::Model

  attr_reader :uk_bank_account_details, :debit_card, :credit_card
  validate :answered_all_questions

  def initialize(params)
    @uk_bank_account_details = params[:uk_bank_account_details]
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

  def answered_all_questions
    if uk_bank_account_details.nil? || debit_card.nil? || credit_card.nil?
      add_no_selection_error
    end
  end

private

  def add_no_selection_error
    errors.add(:base, I18n.t('hub.select_phone.errors.no_selection'))
  end
end
