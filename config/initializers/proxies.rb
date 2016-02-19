API_HOST = ENV.fetch("API_HOST") { raise "An API host must be provided with API_HOST" }
SESSION_PROXY = SessionProxy.new(ApiClient.new(API_HOST))
