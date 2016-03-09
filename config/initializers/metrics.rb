require 'graphite-api'

if CONFIG.metrics_enabled
  graphite_client = GraphiteAPI.new(
      graphite: CONFIG.graphite_host + ':' + CONFIG.graphite_port,
      prefix: CONFIG.graphite_prefix,
      slice: CONFIG.graphite_slice,
      interval: CONFIG.graphite_interval
  )
  event_source = ActiveSupport::Notifications
  controller_action_reporter = Metrics::ControllerActionReporter.new(graphite_client)
  event_subscriber = Metrics::EventSubscriber.new(event_source)
  event_subscriber.subscribe(/process_action.action_controller/, controller_action_reporter)
end
