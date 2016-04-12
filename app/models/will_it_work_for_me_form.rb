class WillItWorkForMeForm
  include ActiveModel::Model

  attr_reader :above_age_threshold, :resident_last_12_months, :not_resident_reason

  def initialize(hash)
    @above_age_threshold = hash[:above_age_threshold]
    @resident_last_12_months = hash[:resident_last_12_months]
  end

  def resident_last_12_months?
    @resident_last_12_months == 'true'
  end
end
