require 'originating_ip_store'

Rails.application.config.after_initialize do
  API_CLIENT = Api::Client.new(CONFIG.api_host, Api::ResponseHandler.new)
  SESSION_PROXY = SessionProxy.new(API_CLIENT, OriginatingIpStore)
end
