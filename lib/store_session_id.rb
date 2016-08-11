require 'cookie_names'
class StoreSessionId
  def initialize(app)
    @app = app
  end

  def call(env)
    request = ActionDispatch::Request.new env
    RequestStore.store[:session_id] = request.cookies[CookieNames::SESSION_ID_COOKIE_NAME]
    @app.call(env)
  end
end
