class MockFingerprintMiddleware
  def initialize(request_log)
    @request_log = request_log
  end

  def call(env)
    request = ActionDispatch::Request.new(env)
    if request.path == '/assets2/fp.gif'
      params = request.params
      @request_log.log(params)
    end
    ['200', {}, ['']]
  end
end
