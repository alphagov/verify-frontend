require 'spec_helper'
require 'models/api/client'
require 'models/cookie_names'
require 'webmock/rspec'
require 'active_support'
require 'connection_pool'

module Api
  describe Client do
    let(:request_body) { { 'a' => 1, 'b' => 2 } }
    let(:response_body) { { 'c' => 3 } }
    let(:host) { 'http://api.com' }
    let(:path) { '/endpoint' }
    let(:response_handler) { double(:response_handler) }
    let(:api_client) { Client.new(host, response_handler) }
    let(:session) { { start_time: 'a-start-time' } }

    context '#get' do
      it 'sets cookies if provided them' do
        stub_request(:get, "#{host}/api#{path}").with(headers: { cookie: /COOKIE_NAME=some-val/ }).and_return(status: 200, body: '{}')
        expect(response_handler).to receive(:handle_response).with(HTTP::Response::Status[200], 200, '{}').and_return(response_body)
        response = api_client.get(path, session, cookies: { 'COOKIE_NAME' => 'some-val' })
        expect(a_request(:get, "#{host}/api#{path}").with(headers: { cookie: /COOKIE_NAME=some-val/ })).to have_been_made.once
        expect(response).to eql response_body
      end

      it 'sets or updates start time cookie from start time in session' do
        start_time_cookie_regex = /#{CookieNames::SESSION_STARTED_TIME_COOKIE_NAME}=a-start-time/
        stub_request(:get, "#{host}/api#{path}")
          .with(headers: { cookie: start_time_cookie_regex })
          .and_return(status: 200, body: '{}')

        expect(response_handler).to receive(:handle_response).with(HTTP::Response::Status[200], 200, '{}').and_return(response_body)
        response = api_client.get(path, session, cookies: { CookieNames::SESSION_STARTED_TIME_COOKIE_NAME => 'old-start-time' })
        expect(a_request(:get, "#{host}/api#{path}").with(headers: { cookie: start_time_cookie_regex })).to have_been_made.once
        expect(response).to eql response_body
      end

      it 'set params if provided them' do
        stub_request(:get, "#{host}/api#{path}").with(query: { 'param1' => 'value1' }).and_return(status: 200, body: '{}')
        expect(response_handler).to receive(:handle_response).with(HTTP::Response::Status[200], 200, '{}').and_return(response_body)
        response = api_client.get(path, session, params: { 'param1' => 'value1' })
        expect(a_request(:get, "#{host}/api#{path}").with(query: { 'param1' => 'value1' })).to have_been_made.once
        expect(response).to eql response_body
      end

      it 'returns a JSON result when successful' do
        stub_request(:get, "#{host}/api#{path}").and_return(status: 200, body: '{}')
        expect(response_handler).to receive(:handle_response).with(HTTP::Response::Status[200], 200, '{}').and_return(response_body)
        response = api_client.get(path, session)
        expect(a_request(:get, "#{host}/api#{path}")).to have_been_made.once
        expect(response).to eql response_body
      end
    end

    context '#post' do
      let(:receive_request) { stub_request(:post, "#{host}/api#{path}").with(body: request_body) }

      context 'successful post' do
        it 'takes a hash and posts it as JSON and returns json result' do
          receive_request.and_return(status: 201, body: '{}')
          expect(response_handler).to receive(:handle_response).with(HTTP::Response::Status[201], 201, '{}').and_return(response_body)
          response = api_client.post(path, request_body, session)
          expect(a_request(:post, "#{host}/api#{path}").with(body: request_body)).to have_been_made.once
          expect(response).to eq response_body
        end
      end

      it 'sets or updates start time cookie from start time in session' do
        start_time_cookie_regex = /#{CookieNames::SESSION_STARTED_TIME_COOKIE_NAME}=a-start-time/
        stub_request(:post, "#{host}/api#{path}")
          .with(body: request_body, headers: { cookie: start_time_cookie_regex })
          .and_return(status: 201, body: '{}')

        expect(response_handler).to receive(:handle_response).with(HTTP::Response::Status[201], 201, '{}').and_return(response_body)
        response = api_client.post(path, request_body, session, cookies: {})
        expect(a_request(:post, "#{host}/api#{path}").with(body: request_body, headers: { cookie: start_time_cookie_regex })).to have_been_made.once
        expect(response).to eql response_body
      end

      it 'uses the correct user agent when acting as a client' do
        receive_request.and_return(status: 201, body: '{}')
        expect(response_handler).to receive(:handle_response).with(HTTP::Response::Status[201], 201, '{}').and_return(response_body).exactly(4).times
        api_client.post(path, request_body, session)
        api_client.post(path, request_body, session)
        api_client.post(path, request_body, session)
        api_client.post(path, request_body, session)
        expect(a_request(:post, "#{host}/api#{path}").with(headers: { 'User-Agent' => 'Verify Frontend Micro Service Client' }))
          .to have_been_made.times(4)
      end
    end

    context '#put' do
      let(:receive_request) { stub_request(:put, "#{host}/api#{path}").with(body: request_body) }

      context 'successful put' do
        it 'takes a hash and puts it as JSON and returns json result' do
          receive_request.and_return(status: 200, body: '{}')
          expect(response_handler).to receive(:handle_response).with(HTTP::Response::Status[200], 200, '{}').and_return(response_body)
          response = api_client.put(path, request_body, session)
          expect(a_request(:put, "#{host}/api#{path}").with(body: request_body)).to have_been_made.once
          expect(response).to eq response_body
        end
      end

      it 'sets or updates start time cookie from start time in session' do
        start_time_cookie_regex = /#{CookieNames::SESSION_STARTED_TIME_COOKIE_NAME}=a-start-time/
        stub_request(:put, "#{host}/api#{path}")
          .with(body: request_body, headers: { cookie: start_time_cookie_regex })
          .and_return(status: 200, body: '{}')

        expect(response_handler).to receive(:handle_response).with(HTTP::Response::Status[200], 200, '{}').and_return(response_body)
        response = api_client.put(path, request_body, session, cookies: {})
        expect(a_request(:put, "#{host}/api#{path}").with(body: request_body, headers: { cookie: start_time_cookie_regex })).to have_been_made.once
        expect(response).to eql response_body
      end
    end

    context 'logging' do
      def notification_payload_for
        payload = nil
        subscription = ActiveSupport::Notifications.subscribe(/api_request/) do |_, _, _, _, the_payload|
          payload = the_payload
        end

        yield

        ActiveSupport::Notifications.unsubscribe(subscription)
        payload
      end

      it 'logs API gets' do
        stub_request(:get, "#{host}/api#{path}").and_return(status: 200, body: '{}')
        expect(response_handler).to receive(:handle_response).with(HTTP::Response::Status[200], 200, '{}').and_return(response_body)

        payload = notification_payload_for { api_client.get(path, session) }

        expect(payload).to eql(path: path, method: 'get')
      end

      it 'logs API puts' do
        stub_request(:put, "#{host}/api#{path}").with(body: request_body).and_return(status: 200, body: '{}')
        expect(response_handler).to receive(:handle_response).with(HTTP::Response::Status[200], 200, '{}').and_return(response_body)

        payload = notification_payload_for { api_client.put(path, request_body, session) }

        expect(payload).to eql(path: path, method: 'put')
      end

      it 'logs API posts' do
        stub_request(:post, "#{host}/api#{path}").with(body: request_body).and_return(status: 201, body: '{}')
        expect(response_handler).to receive(:handle_response).with(HTTP::Response::Status[201], 201, '{}').and_return(response_body)

        payload = notification_payload_for { api_client.post(path, request_body, session) }

        expect(payload).to eql(path: path, method: 'post')
      end
    end
  end
end
