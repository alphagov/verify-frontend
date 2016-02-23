require 'http'
class ApiClient
  DEFAULT_OPTIONS = {cookies: []}

  def initialize(host)
    @host = host
  end

  def get(path, options = DEFAULT_OPTIONS)
    response = client(options).get(uri(path))
    if response.status == 200
      parse_json(response)
    else
      handle_error(response)
    end
  end


  def post(path, body)
    response = client.post(uri(path), json: body)
    if response.status == 201
      parse_json(response)
    else
      handle_error(response)
    end
  end

private

  def handle_error(response)
    json = parse_json(response)
    error_message = json.fetch('message', 'NONE')
    error_id = json.fetch('id', 'NONE')
    raise Error, "Received #{response.status} with error message: '#{error_message}' and id: '#{error_id}'"
  end

  def uri(path)
    @host + "/api" + path
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

  def client(options = DEFAULT_OPTIONS)
    HTTP['User-Agent' => 'Verify Frontend Micro Service Client'].cookies(options[:cookies])
  end
end
