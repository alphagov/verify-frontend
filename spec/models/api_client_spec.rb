require 'spec_helper'
require 'models/api_client'
require 'webmock/rspec'

describe ApiClient do
  let(:request_body) { { "a" => 1, "b" => 2 } }
  let(:host) { 'http://localhost' }
  let(:path) { "/endpoint" }
  let(:response_body) { { 'c' => 3 } }
  let(:receive_request) { stub_request(:post, "#{host}/api#{path}").with(body: request_body) }

  context 'successful post' do
    it 'takes a hash and posts it as JSON and returns json result' do
      receive_request.and_return(status: 201, body: response_body.to_json)
      response = ApiClient.new(host).post(path, request_body)
      expect(a_request(:post, "#{host}/api#{path}").with(body: request_body)).to have_been_made.once
      expect(response).to eq response_body
    end
  end

  context 'successful post but poorly formed response' do
    it 'raises an error when API response is OK but has no JSON' do
      receive_request.and_return(status: 201, body: '')
      expect {
        ApiClient.new(host).post(path, request_body)
      }.to raise_error ApiClient::Error, 'Received 201 Created, but unable to parse JSON'
    end

    it 'raises an error when API response is OK but JSON is malformed' do
      receive_request.and_return(status: 201, body: 'aaaa')
      expect {
        ApiClient.new(host).post(path, request_body)
      }.to raise_error ApiClient::Error, 'Received 201 Created, but unable to parse JSON'
    end
  end

  context 'unsuccessful post' do
    it 'raises an error when API response is not ok with message' do
      receive_request.and_return(status: 500, body: '{"message": "Failure"}')
      expect {
        ApiClient.new(host).post(path, request_body)
      }.to raise_error ApiClient::Error, 'Received 500 Internal Server Error with message: \'Failure\''
    end

    it 'raises an error when API response is not ok with no message' do
      receive_request.and_return(status: 500)
      expect {
        ApiClient.new(host).post(path, request_body)
      }.to raise_error ApiClient::Error, 'Received 500 Internal Server Error, but unable to parse JSON'
    end

    it 'raises an error when API response is not ok with malformed JSON' do
      receive_request.and_return(status: 500, body: 'aaa')
      expect {
        ApiClient.new(host).post(path, request_body)
      }.to raise_error ApiClient::Error, 'Received 500 Internal Server Error, but unable to parse JSON'
    end

    it 'raises an error when API response is not ok with JSON, but message missing' do
      receive_request.and_return(status: 500, body: '{}')
      expect {
        ApiClient.new(host).post(path, request_body)
      }.to raise_error ApiClient::Error, 'Received 500 Internal Server Error with no message'
    end
  end
end
