require 'zendesk_api'

if Rails.env == 'test'
  require 'feedback/dummy_zendesk_client'
  DUMMY_ZENDESK_CLIENT = Feedback::DummyZendeskClient.new
  ZENDESK_CLIENT = ZendeskClient.new(DUMMY_ZENDESK_CLIENT, Rails.logger)
else
  client = ZendeskAPI::Client.new do |config|
    config.url = CONFIG.zendesk_url
    config.username = CONFIG.zendesk_username
    config.token = CONFIG.zendesk_token
    if CONFIG.zendesk_proxy
      config.client_options[:proxy] = { uri: CONFIG.zendesk_proxy }
    end
  end
  ZENDESK_CLIENT = ZendeskClient.new(client, Rails.logger)
end

FEEDBACK_SERVICE = FeedbackService.new(ZENDESK_CLIENT, CONFIG.zendesk_username)
