class SessionResponse < Api::Response
  attr_reader :session_id, :transaction_simple_id, :idps
  validates :session_id, :transaction_simple_id, :idps, presence: true

  def initialize(hash)
    @session_id = hash['sessionId']
    @transaction_simple_id = hash['transactionSimpleId']
    @idps = hash['idps']
  end
end
