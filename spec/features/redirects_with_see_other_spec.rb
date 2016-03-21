require 'feature_helper'
describe 'pages redirect with see other', type: :request do
  it 'sets a see other for redirects' do
    cookie_hash = create_cookie_hash
    cookie_hash.each do |k, v|
      cookies[k] = v
    end
    post '/start', 'selection' => 'true'
    expect(response.status).to eql 303
  end
end
