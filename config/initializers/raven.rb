require 'raven/processor/cookies'
Raven.configure do |config|
  config.ssl_verification = false
  config.processors << Raven::Processor::Cookies
end
