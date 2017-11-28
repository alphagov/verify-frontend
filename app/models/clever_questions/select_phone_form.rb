class CleverQuestions::SelectPhoneForm
  include ActiveModel::Model

  attr_reader :mobile_phone
  validate :answer_not_specified

  def initialize(params)
    @mobile_phone = params[:mobile_phone]
  end

  def selected_answers
    answers = {}
    IdpEligibility::Evidence::PHONE_ONLY_ATTRIBUTES.each do |attr|
      result = public_send(attr)
      if %w(true false).include?(result)
        answers[attr] = result == 'true'
      end
    end
    answers
  end

private

  def add_no_selection_error
    errors.add(:base, I18n.t('hub.select_phone.errors.no_selection'))
  end

  def has_no_mobile_phone?
    mobile_phone == 'false'
  end

  def answer_not_specified
    if mobile_phone.nil?
      add_no_selection_error
    end
  end
end
