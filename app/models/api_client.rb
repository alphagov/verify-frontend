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
      error_type = json.fetch('errorType') {
        raise Error, "Received #{response.status} with no errorType"
      }
      error_id = json.fetch('errorId') {
        raise Error, "Received #{response.status} with no errorId"
      }
      raise Error, "Received #{response.status} with error type: '#{error_type}' and errorId: '#{error_id}'"
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
