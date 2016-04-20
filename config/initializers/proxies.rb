require 'originating_ip_store'
API_HOST = CONFIG.api_host

api_client = Api::Client.new(API_HOST, Api::ResponseHandler.new)

SESSION_PROXY = SessionProxy.new(api_client, OriginatingIpStore)

TRANSACTION_LISTER = Display::Rp::TransactionLister.new(
  Display::Rp::TransactionsProxy.new(api_client),
  Display::Rp::DisplayDataCorrelator.new(FEDERATION_TRANSLATOR))

IDP_DISPLAY_DATA_CORRELATOR = Display::Idp::DisplayDataCorrelator.new(FEDERATION_TRANSLATOR, CONFIG.logo_directory, CONFIG.white_logo_directory)

TRANSACTION_INFO_GETTER = Display::Rp::TransactionInfoGetter.new(
  SESSION_PROXY,
  Display::Rp::Repository.new(FEDERATION_TRANSLATOR)
)
