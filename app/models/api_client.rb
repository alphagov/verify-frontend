require 'http'
class ApiClient
  def initialize(host)
    @host = host
  end

  def post(path, body)
    uri = @host + "/api" + path
    response = HTTP.post(uri, json: body)
    if response.status == 201
      parse_json(response)
    else
      json = parse_json(response)
      message = json.fetch('message') {
        raise Error, "Received #{response.status} with no message"
      }
      raise Error, "Received #{response.status} with message: '#{message}'"
    end
  end

  def parse_json(response)
    begin
      JSON.parse(response.to_s)
    rescue JSON::ParserError
      raise Error, "Received #{response.status}, but unable to parse JSON"
    end
  end

  class Error < StandardError
  end
end
