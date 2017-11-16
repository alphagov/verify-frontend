require 'spec_helper'
require 'rails_helper'
require 'policy_proxy'

describe PolicyProxy do
  let(:api_client) { double(:api_client) }
  let(:originating_ip_store) { double(:originating_ip_store) }
  let(:path) { '/api/session' }
  let(:session_id) { 'my-session-id' }
  let(:policy_proxy) { PolicyProxy.new(api_client, originating_ip_store) }
  let(:ip_address) { '127.0.0.1' }

  include PolicyEndpoints
  def endpoint(suffix_path)
    policy_endpoint(session_id, suffix_path)
  end

  describe('#select_idp') do
    it 'should select an IDP for the session' do
      ip_address = '1.1.1.1'
      body = { PolicyEndpoints::PARAM_SELECTED_ENTITY_ID => 'an-entity-id', PolicyEndpoints::PARAM_PRINCIPAL_IP => ip_address, PolicyEndpoints::PARAM_REGISTRATION => false }
      expect(api_client).to receive(:post)
                                .with(endpoint(PolicyProxy::SELECT_IDP_SUFFIX), body, {})
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      policy_proxy.select_idp(session_id, 'an-entity-id')
    end

    it 'should select an IDP for the session when registering' do
      ip_address = '1.1.1.1'
      body = { PolicyEndpoints::PARAM_SELECTED_ENTITY_ID => 'an-entity-id', PolicyEndpoints::PARAM_PRINCIPAL_IP => ip_address, PolicyEndpoints::PARAM_REGISTRATION => true }
      expect(api_client).to receive(:post)
                                .with(endpoint(PolicyProxy::SELECT_IDP_SUFFIX), body, {})
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      policy_proxy.select_idp(session_id, 'an-entity-id', true)
    end
  end

  describe '#matching_outcome' do
    it 'should return a matching outcome' do
      expect(api_client).to receive(:get)
                                .with(endpoint(PolicyProxy::MATCHING_OUTCOME_SUFFIX))
                                .and_return('responseProcessingStatus' => 'GOTO_HUB_LANDING_PAGE')

      response = policy_proxy.matching_outcome(session_id)

      expect(response).to eql MatchingOutcomeResponse::GOTO_HUB_LANDING_PAGE
    end

    it 'should raise an error when the API responds with an unknown value' do
      expect(api_client).to receive(:get)
                                .with(endpoint(PolicyProxy::MATCHING_OUTCOME_SUFFIX))
                                .and_return('responseProcessingStatus' => 'BANANA')

      expect {
        policy_proxy.matching_outcome(session_id)
      }.to raise_error Api::Response::ModelError, 'Outcome BANANA is not an allowed value for a matching outcome'
    end
  end


  describe '#cycle_three_attribute_name' do
    it 'should return an attribute name' do
      expect(api_client).to receive(:get)
                                .with(endpoint(PolicyProxy::CYCLE_THREE_SUFFIX))
                                .and_return('attributeName' => 'verySpecialNumber')

      actual_response = policy_proxy.cycle_three_attribute_name(session_id)

      expect(actual_response).to eql 'verySpecialNumber'
    end
  end

  describe '#submit_cycle_three_value' do
    it 'should post an attribute value' do
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      expect(api_client).to receive(:post)
                                .with(endpoint(PolicyProxy::CYCLE_THREE_SUBMIT_SUFFIX),
                                      { 'cycle3Input' => 'some value', 'principalIpAddress' => '127.0.0.1' },
                                      {})

      policy_proxy.submit_cycle_three_value(session_id, 'some value')
    end
  end

  describe '#cycle_three_cancel' do
    it 'should post to cancel api endpoint' do
      expect(api_client).to receive(:post)
                                .with(endpoint(PolicyProxy::CYCLE_THREE_CANCEL_SUFFIX),
                                      nil,
                                      {})

      policy_proxy.cycle_three_cancel(session_id)
    end
  end

  describe('#get_countries') do
    countries_json = [
        { 'entityId' => 'http://netherlandsEntity.nl', 'simpleId' => 'NL', 'enabled' => false },
        { 'entityId' => 'http://spainEntity.es', 'simpleId' => 'ES', 'enabled' => true }
    ]
    let(:api_response) { countries_json }

    it 'should retrieve countries' do
      expect(api_client).to receive(:get).with('/policy/countries/my-session-id').and_return(api_response)

      response = policy_proxy.get_countries(session_id)
      expect(response.countries.count).to eq(2)
      response.countries.each do |country|
        case country.simple_id
        when 'ES'
          expect(country).to have_attributes(simple_id: 'ES',
                                                    entity_id: 'http://spainEntity.es',
                                                    enabled: true)
        when 'NL'
          expect(country).to have_attributes(simple_id: 'NL',
                                                    entity_id: 'http://netherlandsEntity.nl',
                                                    enabled: false)
        else
          fail('Invalid list of countries')
        end
      end
    end
  end
end
