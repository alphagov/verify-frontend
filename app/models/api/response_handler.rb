module Api
  class ResponseHandler
    def handle_response(received_status, expected_status, body)
      if received_status == expected_status
        parse_json(body, received_status)
      else
        handle_error(body, received_status)
      end
    end

  private

    def handle_error(body, status)
      json = parse_json(body, status) || {}
      error_message = message(status, json)
      case json.fetch('type') { raise Error, error_message }
      when SessionError::TYPE
        raise SessionError, error_message
      when SessionTimeoutError::TYPE
        raise SessionTimeoutError, error_message
      else
        raise UpstreamError, error_message
      end
    end

    def message(status, json)
      id = json.fetch('id', 'NONE')
      type = json.fetch('type', 'NONE')
      errors = json.fetch('errors', []).join(', ')
      "Received #{status} with error message: [#{errors}], type: '#{type}' and id: '#{id}'"
    end


    def parse_json(body, status)
      return nil if body.empty?
      begin
        JSON.parse(body)
      rescue JSON::ParserError
        raise Error, "Received #{status}, but unable to parse JSON"
      end
    end
  end
end
