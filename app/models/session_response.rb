class SessionResponse < Api::Response
  attr_reader :session_id
  validates :session_id, presence: true

  def initialize(hash)
    @session_id = hash['sessionId']
  end
end
