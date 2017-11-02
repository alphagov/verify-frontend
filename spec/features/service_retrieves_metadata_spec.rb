require 'feature_helper'
require 'api_test_helper'

describe 'service retrieves metadata', type: :request do
  it 'successfully gets sp metadata' do
    xml = '<THING></THING>'
    stub_request(:get, saml_proxy_uri('metadata/idp')).to_return(body: "{\"saml\": \"#{xml}\"}")
    response = get(service_provider_metadata_path)
    expect(response).to eql 200

    expect(@response.body).to eql xml
  end

  it 'handles errors getting sp metadata' do
    stub_request(:get, saml_proxy_uri('metadata/idp')).to_return(status: 500)
    stub_transactions_list
    status = get(service_provider_metadata_path)
    expect(status).to eql 500
  end

  it 'successfully gets idp metadata' do
    xml = '<THING></THING>'
    stub_request(:get, saml_proxy_uri('metadata/sp')).to_return(body: "{\"saml\": \"#{xml}\"}")
    status = get(identity_provider_metadata_path)
    expect(status).to eql 200

    expect(@response.body).to eql xml
  end

  it 'handles errors getting idp metadata' do
    stub_request(:get, saml_proxy_uri('metadata/sp')).to_return(status: 500)
    stub_transactions_list
    status = get(identity_provider_metadata_path)
    expect(status).to eql 500
  end

  def saml_proxy_uri(path)
    URI.join(CONFIG.saml_proxy_host, '/API/', path)
  end
end
