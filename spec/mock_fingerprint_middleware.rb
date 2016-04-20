class MockFingerprintMiddleware < Sinatra::Base
  def initialize(request_log)
    super
    @request_log = request_log
  end

  get '/assets2/fp.gif' do
    @request_log.log(params)
    'OK'
  end
end
