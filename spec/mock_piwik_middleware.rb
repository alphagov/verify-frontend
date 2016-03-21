class MockPiwikMiddleware < Sinatra::Base
  def initialize(logger)
    super
    @logger = logger
  end

  get '/piwik.php' do
    @logger.info(params)
    'OK'
  end
end
