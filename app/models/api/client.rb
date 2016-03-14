require 'http'
module Api
  class Client
    DEFAULT_OPTIONS = {}

    def initialize(host, response_handler, options = {})
      @host = host
      @response_handler = response_handler
      @ssl_context = options[:ssl_context]
    end

    def get(path, options = DEFAULT_OPTIONS)
      response = client(options).get(uri(path), params: options[:params], ssl_context: @ssl_context)
      @response_handler.handle_response(response.status, 200, response.to_s)
    end

    def post(path, body)
      response = ActiveSupport::Notifications.instrument('api_request', path: path, method: 'post') do
        client.post(uri(path), json: body, ssl_context: @ssl_context)
      end
      @response_handler.handle_response(response.status, 201, response.to_s)
    end

    def put(path, body, options = DEFAULT_OPTIONS)
      response = client(options).put(uri(path), json: body, ssl_context: @ssl_context)
      @response_handler.handle_response(response.status, 200, response.to_s)
    end

  private

    def uri(path)
      @host + "/api" + path
    end

    def client(options = DEFAULT_OPTIONS)
      HTTP['User-Agent' => 'Verify Frontend Micro Service Client'].cookies(options.fetch(:cookies, {}))
    end
  end
end
