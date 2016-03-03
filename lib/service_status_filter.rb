class ServiceStatusFilter
  def initialize(app)
    @app = app
  end

  def zdd_latch_file
    CONFIG.zdd_file
  end

  def call(env)
    status, headers, response = @app.call(env)
    if File.exist?(zdd_latch_file)
      [status, headers.merge("Connection" => "close"), response]
    else
      [status, headers, response]
    end
  end
end
