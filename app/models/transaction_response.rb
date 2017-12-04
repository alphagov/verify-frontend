class TransactionResponse < Api::Response
  attr_reader :simple_id, :transaction_homepage, :levels_of_assurance
  validates :simple_id, :transaction_homepage, :levels_of_assurance, presence: true

  def initialize(hash)
    @simple_id = hash['simpleId']
    @transaction_homepage = hash['serviceHomepage']
    @levels_of_assurance = hash['loaList']
  end
end
