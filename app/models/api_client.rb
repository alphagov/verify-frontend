require 'http'
class ApiClient
  def initialize(host)
    @host = host
  end

  def post(path, body)
    uri = @host + "/api" + path
    response = HTTP.post(uri, json: body)
    if response.status == 201
      JSON.parse(response.to_s)
    else
      raise Error, "Received #{response.status} with message: '#{response}'"
    end
  end

  class Error < StandardError
  end
end
