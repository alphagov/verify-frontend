require 'rails_helper'
require 'controller_helper'
require 'api_test_helper'

describe InitiateJourneyController do
  before :each do
    stub_transactions_list
  end

  context 'is called with valid parameters' do
    it 'should redirect to RP headless start page with no journey hint' do
      get :index, params: { transaction_simple_id: 'test-rp', locale: 'en' }

      expect(subject).to redirect_to('http://localhost:50130/success?rp-name=test-rp')
      expect(session[:journey_hint]).to be_nil
      expect(session[:journey_hint_rp]).to eq('test-rp')
    end

    it 'should redirect to RP headless start page with journey hint' do
      get :index, params: { transaction_simple_id: 'test-rp', locale: 'en', journey_hint: 'uk_idp_sign_in' }

      expect(subject).to redirect_to('http://localhost:50130/success?rp-name=test-rp&journey_hint=uk_idp_sign_in')
      expect(session[:journey_hint]).to eq('uk_idp_sign_in')
      expect(session[:journey_hint_rp]).to eq('test-rp')
    end

    it 'should redirect to RP headless start page with journey hint when an IDP-specific one is used' do
      get :index, params: { transaction_simple_id: 'test-rp', locale: 'en', journey_hint: 'idp_stub_idp' }

      expect(subject).to redirect_to('http://localhost:50130/success?rp-name=test-rp&journey_hint=idp_stub_idp')
      expect(session[:journey_hint]).to eq('idp_stub_idp')
      expect(session[:journey_hint_rp]).to eq('test-rp')
    end

    it 'should redirect to service homepage if headless startpage not defined for RP' do
      get :index, params: { transaction_simple_id: 'test-rp-noc3', locale: 'en' }

      expect(subject).to redirect_to('http://localhost:50130/test-rp-noc3')
    end
  end

  context 'is called with invalid parameters' do
    it 'should discard invalid journey hint value before routing to RP' do
      expect(Rails.logger).to receive(:warn).with("Invalid initiate-journey request - RP simple ID = 'test-rp', journey hint = 'bad_journey_hint_value'")
      get :index, params: { transaction_simple_id: 'test-rp', locale: 'en', journey_hint: 'bad_journey_hint_value' }

      expect(subject).to redirect_to('http://localhost:50130/success?rp-name=test-rp')
    end

    it 'should render error page if invalid RP passed' do
      expect(Rails.logger).to receive(:error).with("Invalid initiate-journey request - RP simple ID = 'non-existent-rp', journey hint = ''")
      get :index, params: { transaction_simple_id: 'non-existent-rp', locale: 'en' }

      expect(subject).to render_template("errors/something_went_wrong")
    end
  end
end
