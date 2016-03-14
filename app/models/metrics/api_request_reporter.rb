module Metrics
  class ApiRequestReporter
    KEY_DELIMITER = '.'
    TOTAL_DURATION = 'total_duration'
    COUNT = 'count'

    def initialize(statsd_client)
      @statsd_client = statsd_client
    end

    def report(_name, start, finish, _id, payload)
      # args name and id get passed from ActiveSupport, however we will not need them to report.
      source = ['Api', 'request', payload[:method]]
      @statsd_client.timing(metric_key(source, TOTAL_DURATION), duration(finish, start))
      @statsd_client.increment(metric_key(source, COUNT))
    end

  private

    def duration(finish, start)
      # We would normally output ms, but collectd's statsd plugin expects seconds.
      (finish - start) * 1_000_000
    end

    def metric_key(source, metric)
      [source, metric].join(KEY_DELIMITER)
    end
  end
end
