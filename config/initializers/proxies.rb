API_HOST = ENV.fetch("API_HOST") { raise "An API host must be provided with API_HOST" }
api_client = ApiClient.new(API_HOST)
SESSION_PROXY = SessionProxy.new(api_client)

TRANSACTION_LISTER = Display::Rp::TransactionLister.new(Display::Rp::TransactionsProxy.new(api_client),
                                                        Display::Rp::DisplayDataCorrelator.new)