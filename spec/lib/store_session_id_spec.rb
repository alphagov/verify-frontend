require 'spec_helper'
require 'store_session_id'
require 'rails_helper'

describe StoreSessionId do
  it 'reads the session cookie from the users' do
    env = {
      "HTTP_COOKIE" => "#{CookieNames::SESSION_ID_COOKIE_NAME}=foobarbaz;"
    }
    app = double(:app)
    expect(app).to receive(:call).with(env)
    StoreSessionId.new(app).call(env)
    expect(RequestStore.store[:session_id]).to eql 'foobarbaz'
  end
end
