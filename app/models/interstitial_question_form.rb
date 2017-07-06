class InterstitialQuestionForm
  include ActiveModel::Model

  attr_reader :extra_info
  validate :answer_required

  def initialize(hash)
    @extra_info = hash[:extra_info]
  end

  def selected_answers
    if has_extra_info?
      { "interstitial_yes" => true }
    else
      { "interstitial_no" => true }
    end
  end

  def is_yes_selected
    has_extra_info?
  end

private

  def has_extra_info?
    self.extra_info == 'true'
  end

  def answer_required
    if @extra_info.blank?
      errors.add(:base, [I18n.t('hub.redirect_to_idp_question.validation_message')])
    end
  end
end
