class SessionValidator
  class SessionStartTimeValidator
    def initialize(session_duration)
      @session_duration = session_duration
    end

    def validate(_cookies, session)
      begin
        session_start_time_integer = session.fetch(:start_time)
        session_start_time = Time.at(Integer(session_start_time_integer) / 1000).to_datetime
        validate_expiry(session, session_start_time)
      rescue KeyError
        ValidationFailure.something_went_wrong('start_time not in session')
      end
    end

  private

    def validate_expiry(session, session_start_time)
      if session_start_time <= @session_duration.hours.ago
        session_id = session['verify_session_id']
        ValidationFailure.session_expired(session_id)
      else
        SuccessfulValidation
      end
    end
  end
end
