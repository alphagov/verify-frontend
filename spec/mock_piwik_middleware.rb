class MockPiwikMiddleware < Sinatra::Base
  def initialize(request_log)
    super
    @request_log = request_log
  end

  get '/piwik.php' do
    @request_log.log(params)
    'OK'
  end
end
