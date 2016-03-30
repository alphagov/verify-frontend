require 'originating_ip_store'
API_HOST = CONFIG.api_host

api_client = Api::Client.new(API_HOST, Api::ResponseHandler.new)

SESSION_PROXY = SessionProxy.new(api_client, OriginatingIpStore)

federation_translator = Display::FederationTranslator.new
TRANSACTION_LISTER = Display::Rp::TransactionLister.new(
  Display::Rp::TransactionsProxy.new(api_client),
  Display::Rp::DisplayDataCorrelator.new(federation_translator))

FEDERATION_INFO_GETTER = Display::Federation::FederationInfoGetter.new(
  SESSION_PROXY,
  Display::Idp::DisplayDataCorrelator.new(federation_translator, CONFIG.logo_directory, CONFIG.white_logo_directory))
