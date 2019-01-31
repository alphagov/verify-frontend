require 'rails_helper'
require 'json'
require 'http/response'

module Api
  describe HubResponseHandler do
    let(:response_handler) { HubResponseHandler.new }
    context 'on an unsuccessful response' do
      it 'raises an error with message, id and type from the Hub response' do
        expect {
          response_handler.handle_response(HTTP::Response::Status[500], '{"clientMessage": "Failure", "exceptionType": "BAD THING", "errorId": "1234"}')
        }.to raise_error UpstreamError, /Received 500 with error message: 'Failure', type: 'BAD THING' and id: '1234'/
      end

      it 'raises an error when API response is not ok with JSON, but message missing' do
        expect {
          response_handler.handle_response(HTTP::Response::Status[500], '{}')
        }.to raise_error Error, /Received 500 with error message: 'NONE', type: 'NONE' and id: 'NONE'/
      end

      it 'raises a session error when type is set to SESSION_ERROR' do
        error_body = { clientMessage: 'Failure', errorId: '0', exceptionType: 'EXPECTED_SESSION_STARTED_STATE_ACTUAL_IDP_SELECTED_STATE' }
        expect {
          response_handler.handle_response(HTTP::Response::Status[400], error_body.to_json)
        }.to raise_error SessionError, /Received 400 with error message: 'Failure', type: 'EXPECTED_SESSION_STARTED_STATE_ACTUAL_IDP_SELECTED_STATE' and id: '0'/
      end

      it 'raises a session timeout error when type is set to SESSION_TIMEOUT' do
        error_body = { clientMessage: 'Failure', errorId: '0', exceptionType: 'SESSION_TIMEOUT' }
        expect {
          response_handler.handle_response(HTTP::Response::Status[400], error_body.to_json)
        }.to raise_error SessionTimeoutError, /Received 400 with error message: 'Failure', type: 'SESSION_TIMEOUT' and id: '0'/
      end

      it 'raises an upstream error when type is set, but not SESSION_TIMEOUT or SESSION_ERROR' do
        error_body = { clientMessage: 'Failure', errorId: '0', exceptionType: 'SERVER_ERROR' }
        expect {
          response_handler.handle_response(HTTP::Response::Status[400], error_body.to_json)
        }.to raise_error UpstreamError, /Received 400 with error message: 'Failure', type: 'SERVER_ERROR' and id: '0'/
      end
    end
  end
end
