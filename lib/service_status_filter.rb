require "service_status"
class ServiceStatusFilter
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
    if ServiceStatus.unavailable?
      [status, headers.merge("Connection" => "close"), response]
    else
      [status, headers, response]
    end
  end
end
