api_host = ENV.fetch("API_HOST") { raise "An API host must be provided with API_HOST" }
AUTHN_REQUEST_PROXY = AuthnRequestProxy.new(ApiClient.new(api_host))
