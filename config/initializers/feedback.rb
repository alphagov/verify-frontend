require 'zendesk_api'

if Rails.env == 'test'
  require 'feedback/dummy_zendesk_client'
  ZENDESK_CLIENT = ZendeskClient.new(Feedback::DummyZendeskClient.new, Rails.logger)
else
  client = ZendeskAPI::Client.new do |config|
    config.url = CONFIG.zendesk_url
    config.username = CONFIG.zendesk_username
    config.token = CONFIG.zendesk_token
  end
  ZENDESK_CLIENT = ZendeskClient.new(client, Rails.logger)
end

FEEDBACK_SERVICE = FeedbackService.new(ZENDESK_CLIENT, CONFIG.zendesk_username)
