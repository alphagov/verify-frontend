module Api
  class HubResponseHandler
    ERROR_MESSAGE_PATTERN = "Unexpected error whilst trying to communicate wth the Hub. " \
                            "Received %s with error message: %s, type: '%s' and id: '%s', Referer: '%s'%s\n" \
                            "The Hub may be unreachable. Check all services are running and are accessible".freeze

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
      exception_type = json.fetch('exceptionType') { raise Error, error_message }

      case exception_type
      when SessionError::HUB_TYPE
        raise SessionError, error_message
      when SessionTimeoutError::TYPE
        raise SessionTimeoutError, error_message
      else
        raise UpstreamError.new(exception_type), error_message
      end
    end

    def message(status, json)
      id = json.fetch('errorId', 'NONE')
      type = json.fetch('exceptionType', 'NONE')
      error_message = json.fetch('clientMessage', 'NONE')
      rp_referer = RequestStore.store[:rp_referer]
      rp_saml_request = ''
      if 'INVALID_SAML'.eql? type
        rp_saml_request = ", RelayState: '#{RequestStore.store[:rp_relay_state]}', SAML Request: '#{RequestStore.store[:rp_saml_request]}'"
      end
      ERROR_MESSAGE_PATTERN % [status, "'#{error_message}'", type, id, rp_referer, rp_saml_request]
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
