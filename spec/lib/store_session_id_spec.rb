require 'spec_helper'
require 'store_session_id'
require 'rails_helper'
require 'raven'

describe StoreSessionId do
  it 'reads the session cookie from the users' do
    session_id = 'foobarbaz'
    env = {
      "REQUEST_METHOD" => "GET",
      "HTTP_COOKIE" => "#{CookieNames::SESSION_ID_COOKIE_NAME}=#{session_id};"
    }
    app = double(:app)
    expect(app).to receive(:call).with(env)
    StoreSessionId.new(app).call(env)
    expect(RequestStore.store[:session_id]).to eql session_id
    expect(Raven.context.user[:session_id]).to eql session_id
  end

  it 'throw away non standard HTTP method requests' do
    env = {
        "REQUEST_METHOD" => "DEBUG"
    }
    app = double(:app)
    expect(app).not_to receive(:call).with(env)
    result = StoreSessionId.new(app).call(env)
    expect(result[0]).to eql 405
  end
end
