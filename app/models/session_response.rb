class SessionResponse
  include ActiveModel::Model

  attr_reader :session_id, :session_start_time, :secure_cookie, :transaction_simple_id
  validates :session_id, :session_start_time, :secure_cookie, presence: true

  def initialize(session_id, session_start_time, secure_cookie, transaction_simple_id)
    @session_id = session_id
    @session_start_time = session_start_time
    @secure_cookie = secure_cookie
    @transaction_simple_id = transaction_simple_id
  end
end
