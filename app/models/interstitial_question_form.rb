class InterstitialQuestionForm
  include ActiveModel::Model

  attr_reader :interstitial_question_result
  validate :answer_required

  def initialize(hash)
    @interstitial_question_result = hash[:interstitial_question_result]
  end

  def selected_answers
    if is_yes_selected?
      { "interstitial_yes" => true }
    else
      { "interstitial_no" => true }
    end
  end

  def is_yes_selected?
    self.interstitial_question_result == 'true'
  end

private

  def answer_required
    if @interstitial_question_result.blank?
      errors.add(:base, [I18n.t('hub.redirect_to_idp_question.validation_message')])
    end
  end
end
