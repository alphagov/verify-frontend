require 'rails_helper'
require 'controller_helper'

describe AboutController do
  before(:each) do
    stub_request(:get, CONFIG.api_host + '/api/transactions')
  end

  context 'GET about#certified_companies' do
    subject { get :certified_companies, params: { locale: 'en' } }

    it 'renders the certified companies LOA1 template when LEVEL_1 is the requested LOA' do
      set_session_and_cookies_with_loa('LEVEL_1')
      expect(subject).to render_template(:certified_companies_LOA1)
      expect(subject).to_not render_template(:certified_companies_LOA2)
    end

    it 'renders the certified companies LOA2 template when LEVEL_2 is the requested LOA' do
      set_session_and_cookies_with_loa('LEVEL_2')
      expect(subject).to render_template(:certified_companies_LOA2)
      expect(subject).to_not render_template(:certified_companies_LOA1)
    end
  end

  context 'GET about#identity_accounts' do
    subject { get :identity_accounts, params: { locale: 'en' } }

    it 'renders the identity accounts LOA1 template when LEVEL_1 is the requested LOA' do
      set_session_and_cookies_with_loa('LEVEL_1')
      expect(subject).to render_template(:identity_accounts_LOA1)
      expect(subject).to_not render_template(:identity_accounts_LOA2)
    end

    it 'renders the identity accounts LOA2 template when LEVEL_2 is the requested LOA' do
      set_session_and_cookies_with_loa('LEVEL_2')
      expect(subject).to render_template(:identity_accounts_LOA2)
      expect(subject).to_not render_template(:identity_accounts_LOA1)
    end
  end
end
