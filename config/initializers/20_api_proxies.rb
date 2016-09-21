require 'originating_ip_store'

Rails.application.config.after_initialize do
  API_HOST = CONFIG.api_host
  API_CLIENT = Api::Client.new(API_HOST, Api::ResponseHandler.new)
  SESSION_PROXY = SessionProxy.new(API_CLIENT, OriginatingIpStore)
end
