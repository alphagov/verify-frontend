class MockPiwikMiddleware
  def call(env)
    request = ActionDispatch::Request.new(env)
    if request.path == "/piwik.php"
      params = request.params
      MockPiwikMiddleware.request_log.log(params)
    end
    ["200", {}, [""]]
  end

  def self.request_log; end
end
