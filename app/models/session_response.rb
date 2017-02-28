class SessionResponse < Api::Response
  attr_reader :session_id, :transaction_simple_id, :idps, :levels_of_assurance
  validates :session_id, :transaction_simple_id, :idps, :levels_of_assurance, presence: true

  def initialize(hash)
    @session_id = hash['sessionId']
    @transaction_simple_id = hash['transactionSimpleId']
    @idps = hash['idps']
    @levels_of_assurance = hash['levelsOfAssurance']
  end
end
