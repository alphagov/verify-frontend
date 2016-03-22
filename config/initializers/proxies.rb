require 'ssl_context_factory'
API_HOST = CONFIG.api_host

context = SSLContextFactory.new.create_context(
  cert_path: CONFIG.api_cert_path,
)

api_client = Api::Client.new(API_HOST, Api::ResponseHandler.new, ssl_context: context)
SESSION_PROXY = SessionProxy.new(api_client)

federation_translator = Display::FederationTranslator.new
TRANSACTION_LISTER = Display::Rp::TransactionLister.new(
  Display::Rp::TransactionsProxy.new(api_client),
  Display::Rp::DisplayDataCorrelator.new(federation_translator))

IDENTITY_PROVIDER_LISTER = Display::Idp::IdentityProviderLister.new(
  SESSION_PROXY,
  Display::Idp::DisplayDataCorrelator.new(federation_translator))
