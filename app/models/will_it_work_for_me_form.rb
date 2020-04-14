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
    resident_last_12_months == "true"
  end

  def above_age_threshold?
    above_age_threshold == "true"
  end

  def not_resident_reason
    resident_last_12_months? ? nil : @not_resident_reason
  end

private

  def residency_questions_answered
    if resident_last_12_months.blank?
      errors.add(:resident_last_12_months_true, I18n.t("hub.will_it_work_for_me.question.errors.resident_12_months"))
    end

    if not_resident_missing?
      errors.add(:not_resident_reason_moved_recently, I18n.t("hub.will_it_work_for_me.question.errors.not_resident_reason"))
    end
  end

  def age_threshold_question_answered
    errors.add(:above_age_threshold_true, I18n.t("hub.will_it_work_for_me.question.errors.age_threshold")) if above_age_threshold.blank?
  end

  def not_resident_missing?
    resident_last_12_months == "false" && not_resident_reason.blank?
  end
end
