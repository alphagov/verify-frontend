
class SelectProofOfAddressNoBankAccountForm
  include ActiveModel::Model

  attr_reader :debit_card, :credit_card
  validate :answered_all_questions

  def initialize(params)
    @debit_card = params[:debit_card]
    @credit_card = params[:credit_card]
  end

  def selected_answers
    answers = {}
    IdpEligibility::EvidenceVariant::ADDRESS_DOCUMENT_ATTRIBUTES.each do |attr|
      result = public_send(attr)
      if %w(true false).include?(result)
        answers[attr] = result == 'true'
      end
    end
    answers
  end

  def answered_all_questions
    if debit_card.nil? || credit_card.nil?
      add_no_selection_error
    end
  end

private

  def add_no_selection_error
    errors.add(:base, I18n.t('errors.no_selection'))
  end
end
