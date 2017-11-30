class CleverQuestions::ConfirmingItIsYouForm
  include ActiveModel::Model

  attr_reader :smart_phone

  def initialize(params)
    @smart_phone = params[:smart_phone]
  end

  def selected_answers
    answers = {}
    IdpEligibility::Evidence::SMARTPHONE_ONLY_ATTRIBUTES.each do |attr|
      result = public_send(attr)
      if %w(true false).include?(result)
        answers[attr] = result == 'true'
      end
    end
    answers
  end
end
