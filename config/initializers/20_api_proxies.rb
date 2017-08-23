require 'originating_ip_store'

Rails.application.config.after_initialize do
  IDA_FRONTEND_CLIENT = Api::Client.new(CONFIG.ida_frontend_host, Api::ResponseHandler.new)
  SESSION_PROXY = SessionProxy.new(IDA_FRONTEND_CLIENT, OriginatingIpStore)
  CONFIG_API_CLIENT = Api::Client.new(CONFIG.config_api_host, Api::ResponseHandler.new)
end
