require 'pooling_client'
module Api
  class Client
    def initialize(host, response_handler)
      @host = host
      @response_handler = response_handler
      user_agent = 'Verify Frontend Micro Service Client'
      @client = PoolingClient.new(host, 'User-Agent' => user_agent)
    end

    def get(path, session = {}, options = {})
      map_session_to_cookies(session, options)
      response = log_request(path, 'get') do
        client.get("/api" + path, options)
      end
      @response_handler.handle_response(response.status, 200, response.to_s)
    end

    def post(path, body, session = {}, options = {}, expected_status = 201)
      map_session_to_cookies(session, options)
      response = log_request(path, 'post') do
        client.post(uri(path), body, options)
      end
      @response_handler.handle_response(response.status, expected_status, response.to_s)
    end

    def put(path, body, session = {}, options = {})
      map_session_to_cookies(session, options)
      response = log_request(path, 'put') do
        client.put(uri(path), body, options)
      end
      @response_handler.handle_response(response.status, 200, response.to_s)
    end

  private

    attr_reader :client

    def map_session_to_cookies(session, options)
      unless options.empty? || session.empty?
        if options.has_key?(:cookies)
          options[:cookies].merge!(CookieNames::SESSION_STARTED_TIME_COOKIE_NAME => session[:start_time].to_s)
        end
      end
    end

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
