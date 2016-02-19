require 'rails_helper'
require 'capybara/rspec'
require 'webmock/rspec'

def create_session_start_time_cookie
  DateTime.now.to_i * 1000
end

def api_uri(path)
  "#{API_HOST}/api/#{path}"
end
