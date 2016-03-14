require 'metrics/api_request_reporter'
require 'metrics/controller_action_reporter'
require 'metrics/event_subscriber'

module Metrics
  KEY_DELIMITER = '.'
  TOTAL_DURATION = 'total_duration'
  VIEW_RUNTIME = 'view_runtime'
  COUNT = 'count'

  def self.duration(finish, start)
    # We would normally output ms, but collectd's statsd plugin expects seconds.
    (finish - start) * 1_000_000
  end

  def self.metric_key(source, metric)
    [source, metric].join(KEY_DELIMITER)
  end
end
