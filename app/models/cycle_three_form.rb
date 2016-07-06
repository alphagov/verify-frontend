class CycleThreeForm
  include ActiveModel::Model

  attr_reader :cycle_three_data

  def initialize(hash)
    @cycle_three_data = hash[:cycle_three_data]
  end
end
