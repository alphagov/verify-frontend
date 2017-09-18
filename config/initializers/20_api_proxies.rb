require 'originating_ip_store'

Rails.application.config.after_initialize do
  ida_frontend_client = Api::Client.new(CONFIG.ida_frontend_host, Api::ResponseHandler.new)
  SESSION_PROXY = SessionProxy.new(ida_frontend_client, OriginatingIpStore)

  config_api_client = Api::Client.new(CONFIG.config_api_host, Api::ResponseHandler.new)
  CONFIG_PROXY = ConfigProxy.new(config_api_client)

  saml_proxy_client = Api::Client.new(CONFIG.saml_proxy_host, Api::ResponseHandler.new)
  SAML_PROXY_API = SamlProxyApi.new(saml_proxy_client, OriginatingIpStore)

  policy_client = Api::Client.new(CONFIG.policy_host, Api::ResponseHandler.new)
  POLICY_PROXY = PolicyProxy.new(policy_client, OriginatingIpStore)
end
