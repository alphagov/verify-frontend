require 'http'
class ApiClient
  def initialize(host)
    @host = host
  end

  def post(path, body)
    uri = @host + "/api" + path
    response = client.post(uri, json: body)
    if response.status == 201
      parse_json(response)
    else
      json = parse_json(response)
      error_message = json.fetch('message', 'NONE')
      error_id = json.fetch('id', 'NONE')
      raise Error, "Received #{response.status} with error message: '#{error_message}' and id: '#{error_id}'"
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

private

  def client
    HTTP['User-Agent' => 'Verify Frontend Micro Service Client']
  end
end
