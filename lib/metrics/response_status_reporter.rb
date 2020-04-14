module Metrics
  class ResponseStatusReporter
    def initialize(statsd_client, logger = Rails.logger)
      @statsd_client = statsd_client
      @logger = logger
    end

    def report(_name, _start, _finish, _id, payload)
      if payload[:path] != "/service-status"
        begin
          status_code = Integer(payload[:status])
          @statsd_client.increment("#{status_code / 100}xx_responses")
        rescue TypeError #status code is not a number
          @logger.warn("unable to read status code from response")
        end
      end
    end
  end
end
