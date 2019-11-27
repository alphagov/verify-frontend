require 'spec_helper'
require 'rails_helper'
require 'webmock/rspec'
require 'cgi'

describe PublishHubConfigClient do
  let(:host) { 'http://api.com' }
  let(:api_client) { PublishHubConfigClient.new(host) }

  it 'should return 200 for a sucessful healthcheck' do
    stub_request(:get, "#{host}/service-status").and_return(status: 200, body: '')
    result = api_client.healthcheck
    expect(result.status).to eql(200)
  end

  it 'should return error with the same status as the upstream service' do
    stub_request(:get, "#{host}/service-status").and_return(status: 500, body: 'some error')
    result = api_client.healthcheck
    expect(result.status).to eql(500)
    expect(result.to_s).to eql('some error')
  end

  it 'should return signing certificates for an entity id' do
    signing_certificates = '
      [{
        "issuerId":"http://www.test-rp.gov.uk/SAML2/MD",
        "certificate":"certificate-value",
        "keyUse":"Signing",
        "federationEntityType":"RP"
      }]
    '
    entity_id = 'http://www.test-rp.gov.uk/SAML/MD'
    path = CGI.escape(entity_id) + "/certs/signing"
    stub_request(:get, "#{host}/config/certificates/#{path}").and_return(status: 200, body: signing_certificates)
    result = api_client.certificates(path)
    expect(result.to_s).to eql(signing_certificates)
  end

  it 'should return an encryption certificate for an entity id' do
    encryption_certificate = '
      {
        "issuerId":"http://www.test-rp.gov.uk/SAML2/MD",
        "certificate":"certificate-value",
        "keyUse":"Encryption",
        "federationEntityType":"RP"
      }
    '
    entity_id = 'http://www.test-rp.gov.uk/SAML/MD'
    path = CGI.escape(entity_id) + "/certs/signing"
    stub_request(:get, "#{host}/config/certificates/#{path}").and_return(status: 200, body: encryption_certificate)
    result = api_client.certificates(path)
    expect(result.to_s).to eql(encryption_certificate)
  end

  it 'should return an exception when upstream errors out' do
    error = 'error-message'
    entity_id = 'http://www.test-rp.gov.uk/SAML/MD'
    path = CGI.escape(entity_id) + "/certs/signing"
    stub_request(:get, "#{host}/config/certificates/#{path}").and_return(status: 500, body: error)
    result = api_client.certificates(path)
    expect(result.status).to eql(500)
    expect(result.to_s).to eql(error)
  end
end
