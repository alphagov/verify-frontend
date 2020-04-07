require "originating_ip_store"
require "api"

Rails.application.config.after_initialize do
  config_api_client = Api::Client.new(CONFIG.config_api_host, Api::HubResponseHandler.new)
  CONFIG_PROXY = ConfigProxy.new(config_api_client)

  saml_proxy_client = Api::Client.new(CONFIG.saml_proxy_host, Api::HubResponseHandler.new)
  SAML_PROXY_API = SamlProxyApi.new(saml_proxy_client, OriginatingIpStore)

  policy_client = Api::Client.new(CONFIG.policy_host, Api::HubResponseHandler.new)
  POLICY_PROXY = PolicyProxy.new(policy_client, OriginatingIpStore)
end
