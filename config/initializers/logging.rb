# Logstash
if Rails.env == "production"
  LogStashLogger.configure do |config|
    config.customize_event do |event|
      event["SessionId"] = RequestStore.store[:session_id] || "no-current-session"
      event["level"] = event.remove "severity"
      event["service-name"] = "front"
    end
  end
  logger = LogStashLogger.new(type: :file, path: "log/front.logstash.log", formatter: :json_lines)
  Rails.logger.extend(ActiveSupport::Logger.broadcast(logger))
end

# Raven
require "raven/processor/cookies"
require "support/raven/logger"

Raven.configure do |config|
  config.ssl_verification = false
  config.processors << Raven::Processor::Cookies
end

Rails.logger.extend(ActiveSupport::Logger.broadcast(Support::Raven::Logger.new))
