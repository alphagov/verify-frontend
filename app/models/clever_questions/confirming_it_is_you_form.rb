class CleverQuestions::ConfirmingItIsYouForm
  include ActiveModel::Model

  attr_reader :no_smart_phone

  def initialize(params)
    @no_smart_phone = params[:no_smart_phone]
  end

  def selected_answers
    { smart_phone: has_smart_phone }
  end

private

  def has_smart_phone
    @no_smart_phone == 'true' ? false : true
  end
end
