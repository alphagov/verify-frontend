class MockPiwikMiddleware
  def initialize(request_log)
    @request_log = request_log
  end

  def call(env)
    request = ActionDispatch::Request.new(env)
    if request.path == '/piwik.php'
      params = request.params
      @request_log.log(params)
    end
    ['200', {}, ['']]
  end
end
