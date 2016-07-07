require 'originating_ip_store'
API_HOST = CONFIG.api_host

Rails.application.config.to_prepare do
  api_client = Api::Client.new(API_HOST, Api::ResponseHandler.new)
  SESSION_PROXY = SessionProxy.new(api_client, OriginatingIpStore)
  TRANSACTION_LISTER = Display::Rp::TransactionLister.new(
    Display::Rp::TransactionsProxy.new(api_client),
    Display::Rp::DisplayDataCorrelator.new(FEDERATION_TRANSLATOR)
  )
end

Rails.application.config.after_initialize do
  IDENTITY_PROVIDER_DISPLAY_DECORATOR = Display::IdentityProviderDisplayDecorator.new(
    IDP_DISPLAY_REPOSITORY,
    CONFIG.logo_directory,
    CONFIG.white_logo_directory
  )
end
