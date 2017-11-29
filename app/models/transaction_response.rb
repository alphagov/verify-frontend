class TransactionResponse < Api::Response
  attr_reader :simple_id, :levels_of_assurance
  validates :simple_id, :levels_of_assurance, presence: true

  def initialize(hash)
    @simple_id = hash['simpleId']
    @levels_of_assurance = hash['loaList']
  end
end
