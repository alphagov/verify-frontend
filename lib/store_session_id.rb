require 'cookie_names'
class StoreSessionId
  def initialize(app)
    @app = app
  end

  def call(env)
    request = ActionDispatch::Request.new env
    session_id = request.cookies[CookieNames::SESSION_ID_COOKIE_NAME]
    RequestStore.store[:session_id] = session_id
    Raven.user_context(session_id: session_id)
    @app.call(env)
  end
end
