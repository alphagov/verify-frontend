module Metrics
  class StatsdClient
    def initialize(statsd_client)
      @statsd_client = statsd_client
    end

    def send(key, value)
      @statsd_client.timing(key, value)
    end
  end
end
