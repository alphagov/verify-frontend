require 'spec_helper'
require 'rails_helper'
require 'models/policy_proxy'

describe PolicyProxy do
  let(:api_client) { double(:api_client) }
  let(:originating_ip_store) { double(:originating_ip_store) }
  let(:path) { '/api/session' }
  let(:session_id) { 'my-session-id' }
  let(:policy_proxy) { PolicyProxy.new(api_client, originating_ip_store) }
  let(:ip_address) { '127.0.0.1' }

  def endpoint(suffix_path)
    policy_endpoint(session_id, suffix_path)
  end

  describe('#select_idp') do
    it 'should select an IDP for the session' do
      ip_address = '1.1.1.1'
      body = { PolicyEndpoints::PARAM_SELECTED_ENTITY_ID => 'an-entity-id', PolicyEndpoints::PARAM_PRINCIPAL_IP => ip_address, PolicyEndpoints::PARAM_REGISTRATION => false }
      expect(api_client).to receive(:post)
                                .with(endpoint(PolicyProxy::SELECT_IDP_SUFFIX), body, {}, 201)
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      policy_proxy.select_idp(session_id, 'an-entity-id')
    end

    it 'should select an IDP for the session when registering' do
      ip_address = '1.1.1.1'
      body = { PolicyEndpoints::PARAM_SELECTED_ENTITY_ID => 'an-entity-id', PolicyEndpoints::PARAM_PRINCIPAL_IP => ip_address, PolicyEndpoints::PARAM_REGISTRATION => true }
      expect(api_client).to receive(:post)
                                .with(endpoint(PolicyProxy::SELECT_IDP_SUFFIX), body, {}, 201)
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      policy_proxy.select_idp(session_id, 'an-entity-id', true)
    end
  end
end
