require 'spec_helper'
require 'json'
require 'models/api/response_handler'
require 'models/api/session_error'
require 'models/api/session_timeout_error'
require 'models/api/error'

module Api
  describe ResponseHandler do
    let(:response_handler) { ResponseHandler.new }
    context 'on a successful response' do
      it 'should return a parsed response body on a successful response' do
        expected_result = {'id' => '12'}
        result = response_handler.handle_response(200, 200, expected_result.to_json)
        expect(result).to eq(expected_result)
      end

      it 'should return nil when response is OK but JSON is empty' do
        expect(response_handler.handle_response(200, 200, '')).to be_nil
      end

      it 'errors on receiving malformed JSON' do
        expect {
          response_handler.handle_response(200, 200, 'aaa')
        }.to raise_error Error, 'Received 200, but unable to parse JSON'
      end
    end

    context 'on an unsuccessful response' do
      it 'errors when receiving 500 and empty JSON' do
        expect {
          response_handler.handle_response(500, 200, '')
        }.to raise_error Error, 'Received 500 with error message: \'NONE\' and id: \'NONE\''
      end

      it 'raises an error when API response is not ok with message' do
        expect {
          response_handler.handle_response(400, 200, '{"message": "Failure"}')
        }.to raise_error Error, 'Received 400 with error message: \'Failure\' and id: \'NONE\''
      end

      it 'raises an error when API response is not ok with id' do
        expect {
          response_handler.handle_response(500, 200, '{"id": "1234"}')
        }.to raise_error Error, 'Received 500 with error message: \'NONE\' and id: \'1234\''
      end


      it 'raises an error when API response is not ok with malformed JSON' do
        expect {
          response_handler.handle_response(500, 200, 'aaa')
        }.to raise_error Error, 'Received 500, but unable to parse JSON'
      end

      it 'raises an error when API response is not ok with JSON, but message missing' do
        expect {
          response_handler.handle_response(500, 200, '{}')
        }.to raise_error Error, 'Received 500 with error message: \'NONE\' and id: \'NONE\''
      end

      it 'raises a session error' do
        error_body = {id: '0', type: 'SESSION_ERROR'}
        expect {
          response_handler.handle_response(400, 200, error_body.to_json)
        }.to raise_error SessionError, 'Received 400 with type: \'SESSION_ERROR\' and id: \'0\''
      end

      it 'raises a session timeout error' do
        error_body = {id: '0', type: 'SESSION_TIMEOUT'}
        expect {
          response_handler.handle_response(400, 200, error_body.to_json)
        }.to raise_error SessionTimeoutError, 'Received 400 with type: \'SESSION_TIMEOUT\' and id: \'0\''
      end
    end
  end
end
