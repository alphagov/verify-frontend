require 'rails_helper'

RSpec.describe AboutController do
  describe 'GET about#certified_companies' do
    subject { get :certified_companies, params: { locale: 'en' } }

    before(:each) do
      session[:verify_session_id] = 'my-session-id-cookie'
      session[:transaction_simple_id] = 'test-rp'
      session[:identity_providers] = [{ 'simple_id' => 'stub-idp-one', 'entity_id' => 'http://idcorp.com' }]
      session[:start_time] = DateTime.now.to_i * 1000
      cookies[CookieNames::SESSION_COOKIE_NAME] = 'my-session-cookie'
      cookies[CookieNames::SESSION_ID_COOKIE_NAME] = 'my-session-id-cookie'
    end

    it 'renders the certified companies LOA1 template when LEVEL_1 is the requested LOA' do
      session[:requested_loa] = 'LEVEL_1'
      expect(subject).to render_template(:certified_companies_LOA1)
      expect(subject).to_not render_template(:certified_companies_LOA2)
    end

    it 'renders the certified companies LOA2 template when LEVEL_2 is the requested LOA' do
      session[:requested_loa] = 'LEVEL_2'
      expect(subject).to render_template(:certified_companies_LOA2)
      expect(subject).to_not render_template(:certified_companies_LOA1)
    end
  end
end
