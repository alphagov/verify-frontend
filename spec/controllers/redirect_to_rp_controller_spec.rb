require 'rails_helper'
require 'controller_helper'
require 'api_test_helper'
require 'piwik_test_helper'

describe RedirectToRpController do
  TEST_RP = 'test-rp'.freeze
  REDIRECT_TO_RP_LIST_MOCK = { TEST_RP => { 'url' => 'http://localhost:50300/test-saml', 'ab_test' => 'test_ab_test' } }.freeze

  before :each do
    stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
  end

  context '#redirect_to_rp' do
    context 'should redirect to rp page if rp is in the list' do
      subject { get :redirect_to_rp, params: { locale: 'en', transaction_simple_id: TEST_RP } }

      it 'should redirect to the rp page' do
        expect(FEDERATION_REPORTER).to receive(:report_external_ab_test).with(
          a_kind_of(ActionDispatch::Request),
          'test_ab_test'
        )
        expect(subject).to redirect_to(REDIRECT_TO_RP_LIST_MOCK[TEST_RP]['url'])
      end
    end

    context 'should redirect to start page if the rp is not in the list' do
      subject { get :redirect_to_rp, params: { locale: 'en', transaction_simple_id: 'a-different-rp' } }

      it 'should redirect to the rp page' do
        expect(subject).to redirect_to(start_path)
      end
    end
  end
end
