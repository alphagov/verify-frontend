require 'rails_helper'
require 'models/ab_test/ab_test'
require 'models/ab_test/experiment'

module AbTest
  describe AbTest do
    context '#report' do
      let(:excluded_rp_simple_id) { 'RP is excluded from AB test'.freeze }
      let(:request) { RequestStub.new(nil, nil) }
      before(:each) {
        stub_const('RP_CONFIG', 'ab_test_blacklist' => excluded_rp_simple_id)
        allow(request).to receive(:session).and_return(transaction_simple_id: 'rp')
      }

      context 'cookie matches one of the alternatives' do
        before(:each) {
          allow(request).to receive(:cookies).and_return(CookieNames::AB_TEST => { logos: 'logos_no' }.to_json)
        }

        it 'should set the flash variable if there are multiple alternatives' do
          alternatives = { 'logos' => { 'alternatives' => [{ 'name' => 'yes', 'percent' => 75 }, { 'name' => 'no', 'percent' => 25 }] } }
          stub_const('AB_TESTS', 'logos' => Experiment.new(alternatives))
          subject.report_ab_test_details(request, 'logos')
          expect(request.flash).to eq(ab_test_variant: 'logos_no')
        end

        it 'should not set the flash variable if the experiment is concluded' do
          alternatives = { 'logos' => { 'alternatives' => [{ 'name' => 'yes', 'percent' => 75 }] } }
          stub_const('AB_TESTS', 'logos' => Experiment.new(alternatives))
          subject.report_ab_test_details(request, 'logos')
          expect(request.flash).to eq({})
        end

        it 'should not set the flash variable if there is no alternative' do
          stub_const('AB_TESTS', {})
          subject.report_ab_test_details(request, 'logos')
          expect(request.flash).to eq({})
        end

        it 'should not set the flash variable if RP is in AB test blacklist' do
          allow(request).to receive(:session).and_return(transaction_simple_id: excluded_rp_simple_id)
          alternatives = { 'logos' => { 'alternatives' => [{ 'name' => 'yes', 'percent' => 75 }, { 'name' => 'no', 'percent' => 25 }] } }
          stub_const('AB_TESTS', 'logos' => Experiment.new(alternatives))
          subject.report_ab_test_details(request, 'logos')
          expect(request.flash).to eq({})
        end
      end

      context 'cookie does not match any of the alternatives' do
        before(:each) {
          allow(request).to receive(:cookies).and_return(CookieNames::AB_TEST => { logos: 'logos_not_an_alternative' }.to_json)
        }

        it 'should set the flash variable if there are multiple alternatives' do
          alternatives = { 'logos' => { 'alternatives' => [{ 'name' => 'yes', 'percent' => 75 }, { 'name' => 'no', 'percent' => 25 }] } }
          stub_const('AB_TESTS', 'logos' => Experiment.new(alternatives))
          subject.report_ab_test_details(request, 'logos')
          expect(request.flash).to eq(ab_test_variant: 'logos_yes')
        end
      end
    end
  end

  class RequestStub
    attr_accessor :flash

    def initialize(session, cookies)
      @session = session
      @cookies = cookies
      @flash = {}
    end

    def session; end

    def cookies; end
  end
end
