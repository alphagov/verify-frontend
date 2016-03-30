require 'connection_pool'
require 'http'

class PoolingClient
  attr_reader :client_pool
  def initialize(host, headers = {})
    @client_pool = ConnectionPool.new(size: 36, timeout: 5) do
      HTTP
        .persistent(host)
        .headers(headers)
    end
  end

  def get(path, options = {})
    client_pool.with do |client|
      client
        .cookies(options.fetch(:cookies, {}))
        .headers(options.fetch(:headers, {}))
        .get(path, params: options[:params])
        .flush
    end
  end

  def post(path, body, options = {})
    client_pool.with do |client|
      client
        .cookies(options.fetch(:cookies, {}))
        .headers(options.fetch(:headers, {}))
        .post(path, json: body)
        .flush
    end
  end

  def put(path, body, options = {})
    client_pool.with do |client|
      client
        .cookies(options.fetch(:cookies, {}))
        .headers(options.fetch(:headers, {}))
        .put(path, json: body)
        .flush
    end
  end
end
