module Api
  class ResponseHandler
    ERROR_MESSAGE_PATTERN = "Received %s with error message: %s, type: '%s' and id: '%s'".freeze

    def handle_response(response_status, response_body)
      if response_status.success?
        parse_json(response_body, response_status.code)
      else
        handle_error(response_body, response_status.code)
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
      ERROR_MESSAGE_PATTERN % [status, "[#{errors}]", type, id]
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
