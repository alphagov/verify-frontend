class InterstitialQuestionForm
  include ActiveModel::Model

  attr_reader :extra_info
  validate :answer_required

  def initialize(hash)
    @extra_info = hash[:extra_info]
  end

  def has_extra_info?
    self.extra_info == 'true'
  end

private

  def answer_required
    if @extra_info.blank?
      errors.add(:base, [I18n.t('hub.redirect_to_idp_question.validation_message')])
    end
  end
end
