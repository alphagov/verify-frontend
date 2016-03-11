require 'statsd-ruby'

if CONFIG.metrics_enabled
  event_source = ActiveSupport::Notifications
  statsd_client = Statsd.new(CONFIG.statsd_host, CONFIG.statsd_port)
  controller_action_reporter = Metrics::ControllerActionReporter.new(statsd_client)
  event_subscriber = Metrics::EventSubscriber.new(event_source)
  event_subscriber.subscribe(/process_action.action_controller/, controller_action_reporter)
end
