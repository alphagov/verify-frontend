class SessionResponse < Api::Response
  attr_reader :session_id, :transaction_simple_id
  validates :session_id, :transaction_simple_id, presence: true

  def initialize(hash)
    @session_id = hash['sessionId']
    @transaction_simple_id = hash['transactionSimpleId']
  end
end
