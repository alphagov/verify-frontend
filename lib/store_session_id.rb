class StoreSessionId
  def initialize(app)
    @app = app
  end

  def call(env)
    if %w(POST GET PUT).exclude? env['REQUEST_METHOD']
      return [405, { "Content-Type" => "text/plain" }, ["Method Not Allowed\n"]]
    end

    request = ActionDispatch::Request.new env
    session_id = request.cookies[CookieNames::SESSION_ID_COOKIE_NAME]
    RequestStore.store[:session_id] = session_id
    Raven.user_context(session_id: session_id)

    @app.call(env)
  end
end
