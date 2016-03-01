class ApiResponseHandler
  def handle_response(received_status, expected_status, body)
    if received_status == expected_status
      parse_json(body, received_status)
    else
      handle_error(body, received_status)
    end
  end

private

  def handle_error(body, status)
    json = parse_json(body, status)
    error_message = json.fetch('message', 'NONE')
    error_id = json.fetch('id', 'NONE')
    error_type = json.fetch('type', 'NONE')
    case error_type
    when ApiClient::SessionError::TYPE
      raise ApiClient::SessionError, "Received #{status} with type: '#{error_type}' and id: '#{error_id}'"
    when ApiClient::SessionTimeoutError::TYPE
      raise ApiClient::SessionTimeoutError, "Received #{status} with type: '#{error_type}' and id: '#{error_id}'"
    else
      raise ApiClient::Error, "Received #{status} with error message: '#{error_message}' and id: '#{error_id}'"
    end
  end


  def parse_json(body, status)
    begin
      JSON.parse(body)
    rescue JSON::ParserError
      raise ApiClient::Error, "Received #{status}, but unable to parse JSON"
    end
  end
end
