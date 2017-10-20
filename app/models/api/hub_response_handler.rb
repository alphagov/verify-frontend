module Api
  class HubResponseHandler < ResponseHandler
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
  end
end
