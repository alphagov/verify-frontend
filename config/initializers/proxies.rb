API_HOST = ENV.fetch("API_HOST") { raise "An API host must be provided with API_HOST" }
api_client = Api::Client.new(API_HOST, Api::ResponseHandler.new)
SESSION_PROXY = SessionProxy.new(api_client)

federation_translator = Display::FederationTranslator.new
TRANSACTION_LISTER = Display::Rp::TransactionLister.new(
  Display::Rp::TransactionsProxy.new(api_client),
  Display::Rp::DisplayDataCorrelator.new(federation_translator))

IDENTITY_PROVIDER_LISTER = Display::Idp::IdentityProviderLister.new(
  SESSION_PROXY,
  Display::Idp::DisplayDataCorrelator.new(federation_translator, ENV.fetch('LOGO_DIRECTORY')))
