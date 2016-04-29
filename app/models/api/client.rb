require 'pooling_client'
module Api
  class Client
    def initialize(host, response_handler)
      @host = host
      @response_handler = response_handler
      user_agent = 'Verify Frontend Micro Service Client'
      @client = PoolingClient.new(host, 'User-Agent' => user_agent)
    end

    def get(path, options = {})
      response = log_request(path, 'get') do
        client.get("/api" + path, options)
      end
      @response_handler.handle_response(response.status, 200, response.to_s)
    end

    def post(path, body)
      response = log_request(path, 'post') do
        client.post(uri(path), body)
      end
      @response_handler.handle_response(response.status, 201, response.to_s)
    end

    def put(path, body, options = {})
      response = log_request(path, 'put') do
        client.put(uri(path), body, options)
      end
      @response_handler.handle_response(response.status, 200, response.to_s)
    end

  private

    attr_reader :client

    def log_request(path, method)
      ActiveSupport::Notifications.instrument('api_request', path: path, method: method) do
        yield
      end
    end

    def uri(path)
      "/api" + path
    end
  end
end
