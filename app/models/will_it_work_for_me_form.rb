class WillItWorkForMeForm
  include ActiveModel::Model

  attr_reader :above_age_threshold, :resident_last_12_months

  validate :age_threshold_question_answered, :residency_questions_answered

  def initialize(hash)
    @above_age_threshold = hash[:above_age_threshold]
    @resident_last_12_months = hash[:resident_last_12_months]
    @not_resident_reason = hash[:not_resident_reason]
  end

  def resident_last_12_months?
    resident_last_12_months == 'true'
  end

  def above_age_threshold?
    above_age_threshold == 'true'
  end

  def not_resident_reason
    resident_last_12_months? ? nil : @not_resident_reason
  end

private

  def residency_questions_answered
    if resident_last_12_months.blank?
      no_selection_error
    end

    if !resident_last_12_months? && not_resident_reason.blank?
      no_selection_error
    end
  end

  def age_threshold_question_answered
    if above_age_threshold.blank?
      no_selection_error
    end
  end

  def no_selection_error
    errors.add(:base, I18n.t('hub.will_it_work_for_me.question.errors.no_selection'))
    throw(:abort)
  end
end
