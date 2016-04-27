require 'metrics/api_request_reporter'
require 'metrics/controller_action_reporter'
require 'metrics/event_subscriber'

module Metrics
  KEY_DELIMITER = '.'.freeze
  TOTAL_DURATION = 'total_duration'.freeze
  VIEW_RUNTIME = 'view_runtime'.freeze
  COUNT = 'count'.freeze

  def self.duration(finish, start)
    # The statsd plugin for collectd expects timing values in ms
    (finish - start) * 1_000
  end

  def self.metric_key(source, metric)
    [source, metric].join(KEY_DELIMITER)
  end
end
