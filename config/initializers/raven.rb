Raven.configure do |config|
  config.ssl_verification = false
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
end
