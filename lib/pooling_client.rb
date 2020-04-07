require "connection_pool"
require "http"

class PoolingClient
  attr_reader :client_pool
  def initialize(host, headers = {})
    @client_pool = ConnectionPool.new(size: 36, timeout: 5) do
      HTTP
        .headers(headers)
        .persistent(host)
    end
  end

  def get(path, options = {})
    cookies = transform_cookies(options.fetch(:cookies, {}))
    client_pool.with do |client|
      client
        .get(path, options.merge(cookies: cookies))
        .flush
    end
  end

  def post(path, body, options = {})
    cookies = transform_cookies(options.fetch(:cookies, {}))
    client_pool.with do |client|
      client
        .post(path, json: body, cookies: cookies, headers: options.fetch(:headers, {}))
        .flush
    end
  end

  def put(path, body, options = {})
    cookies = transform_cookies(options.fetch(:cookies, {}))
    client_pool.with do |client|
      client
        .put(path, options.merge(json: body, cookies: cookies))
        .flush
    end
  end

private

  def transform_cookies(cookies)
    cookies.inject({}) { |jar, (name, value)|
      jar[name] = HTTP::Cookie.new(name, value)
      jar
    }
  end
end
