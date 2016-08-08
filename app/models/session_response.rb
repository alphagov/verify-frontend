class SessionResponse < Api::Response
  attr_reader :session_id, :secure_cookie, :transaction_simple_id
  validates :session_id, :secure_cookie, :transaction_simple_id, presence: true

  def initialize(hash)
    @session_id = hash['sessionId']
    @secure_cookie = hash['secureCookie']
    @transaction_simple_id = hash['transactionSimpleId']
  end
end
