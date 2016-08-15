require 'spec_helper'
require 'store_session_id'
require 'rails_helper'
require 'raven'

describe StoreSessionId do
  it 'reads the session cookie from the users' do
    session_id = 'foobarbaz'
    env = {
      "HTTP_COOKIE" => "#{CookieNames::SESSION_ID_COOKIE_NAME}=#{session_id};"
    }
    app = double(:app)
    expect(app).to receive(:call).with(env)
    StoreSessionId.new(app).call(env)
    expect(RequestStore.store[:session_id]).to eql session_id
    expect(Raven.context.user[:session_id]).to eql session_id
  end
end
