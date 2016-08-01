require 'feature_helper'
require 'api_test_helper'

describe 'service retrieves metadata' do
  it "successfully gets sp metadata" do
    xml = '<THING></THING>'
    stub_request(:get, saml_proxy_uri('metadata/sp')).to_return(body: "{\"saml\": \"#{xml}\"}")
    visit service_provider_metadata_path
    expect(page.status_code).to eql 200

    expect(page.body).to eql xml
  end

  it "handles errors getting sp metadata" do
    stub_request(:get, saml_proxy_uri('metadata/sp')).to_return(status: 500)
    stub_transactions_list
    visit service_provider_metadata_path
    expect(page.status_code).to eql 500
    #Todo - this error returns html. Gross.
  end

  it "successfully gets idp metadata" do
    xml = '<THING></THING>'
    stub_request(:get, saml_proxy_uri('metadata/idp')).to_return(body: "{\"saml\": \"#{xml}\"}")
    visit identity_provider_metadata_path
    expect(page.status_code).to eql 200

    expect(page.body).to eql xml
  end

  it "handles errors getting idp metadata" do
    stub_request(:get, saml_proxy_uri('metadata/idp')).to_return(status: 500)
    stub_transactions_list
    visit identity_provider_metadata_path
    expect(page.status_code).to eql 500
    #Todo - this error returns html. Gross.
  end

  def saml_proxy_uri(path)
    URI.join(SAML_PROXY_HOST, '/API/', path)
  end
end
