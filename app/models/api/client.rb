require 'http'
module Api
  class Client
    DEFAULT_OPTIONS = {}

    def initialize(host, response_handler)
      @host = host
      @response_handler = response_handler
    end

    def get(path, options = DEFAULT_OPTIONS)
      response = client(options).get(uri(path), params: options[:params])
      @response_handler.handle_response(response.status, 200, response.to_s)
    end

    def post(path, body)
      response = client.post(uri(path), json: body)
      @response_handler.handle_response(response.status, 201, response.to_s)
    end

    def put(path, body, options = DEFAULT_OPTIONS)
      response = client(options).put(uri(path), json: body)
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
