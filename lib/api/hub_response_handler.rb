module Api
  class HubResponseHandler
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
      case json.fetch('exceptionType') { raise Error, error_message }
      when SessionError::HUB_TYPE
        raise SessionError, error_message
      when SessionTimeoutError::TYPE
        raise SessionTimeoutError, error_message
      else
        raise UpstreamError, error_message
      end
    end

    def message(status, json)
      id = json.fetch('errorId', 'NONE')
      type = json.fetch('exceptionType', 'NONE')
      error_message = json.fetch('clientMessage', 'NONE')
      ERROR_MESSAGE_PATTERN % [status, "'#{error_message}'", type, id]
    end

    def parse_json(body, status)
      return nil if body.empty?

      begin
        MultiJson.load(body)
      rescue MultiJson::ParseError
        raise Error, "Received #{status}, but unable to parse JSON"
      end
    end
  end
end
