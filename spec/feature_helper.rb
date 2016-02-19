require 'rails_helper'
require 'capybara/rspec'
require 'webmock/rspec'

def api_transactions_endpoint
  'http://localhost:50190/api/transactions'
end

def stub_transactions_list
  transactions = {
      'public' => [
          {'simpleId' => 'test-rp', 'entityId' => 'some-entity-id', 'homepage' => 'http://localhost:50130/test-rp'}
      ],
      'private' => []
  }
  stub_request(:get, api_transactions_endpoint).to_return(body: transactions.to_json, status: 200)
end


def create_session_start_time_cookie
  DateTime.now.to_i * 1000
end

def api_uri(path)
  "#{API_HOST}/api/#{path}"
end
