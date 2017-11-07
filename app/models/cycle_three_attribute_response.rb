class CycleThreeAttributeResponse < Api::Response
  attr_reader :name
  validates_presence_of :name

  def initialize(hash)
    @name = hash['attributeName']
  end
end
