require 'rails_helper'
require 'controller_helper'
require 'api_test_helper'

describe RedirectToIdpWarningVariantController do
  before :each do
    set_session_and_cookies_with_loa('LEVEL_2')
    session[:selected_idp_was_recommended] = [true, false].sample
  end

  context 'renders idp logos' do
    subject { get :logos, params: { locale: 'en' } }

    it 'warning page when idp selected' do
      session[:selected_idp] = { 'simple_id' => 'stub-idp-two',
                                 'entity_id' => 'http://idcorp.com',
                                 'levels_of_assurance' => %w(LEVEL_1 LEVEL_2) }

      expect(subject).to render_template(:logos)
    end

    it 'error page when no idp selected' do
      session[:selected_idp] = {}

      expect(subject).to render_template('errors/something_went_wrong')
    end
  end

  context 'renders idp bullets' do
    subject { get :bullets, params: { locale: 'en' } }

    it 'warning page when idp selected' do
      session[:selected_idp] = { 'simple_id' => 'stub-idp-two',
                                 'entity_id' => 'http://idcorp.com',
                                 'levels_of_assurance' => %w(LEVEL_1 LEVEL_2) }

      expect(subject).to render_template(:bullets)
    end

    it 'error page when no idp selected' do
      session[:selected_idp] = {}

      expect(subject).to render_template('errors/something_went_wrong')
    end
  end
end
