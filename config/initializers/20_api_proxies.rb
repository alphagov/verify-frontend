require 'originating_ip_store'

Rails.application.config.after_initialize do
  ida_frontend_client = Api::Client.new(CONFIG.ida_frontend_host, Api::ResponseHandler.new)
  SESSION_PROXY = SessionProxy.new(ida_frontend_client, OriginatingIpStore)
  config_api_client = Api::Client.new(CONFIG.config_api_host, Api::ResponseHandler.new)
  CONFIG_PROXY = ConfigProxy.new(config_api_client)
end
