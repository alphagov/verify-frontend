require 'raven/processor/cookies'
require 'support/raven/logger'

Raven.configure do |config|
  config.ssl_verification = false
  config.processors << Raven::Processor::Cookies
end

Rails.logger.extend(ActiveSupport::Logger.broadcast(Support::Raven::Logger.new))
