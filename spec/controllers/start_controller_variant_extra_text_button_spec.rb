require 'rails_helper'
require 'controller_helper'
require 'api_test_helper'
require 'piwik_test_helper'

describe StartVariantExtraTextButtonController do
  before(:each) do
    stub_piwik_request_with_rp('action_name' => 'The user has reached the start page')
  end

  context 'LOA2' do
    it 'renders LOA2 start page if service is level 2' do
      set_session_and_cookies_with_loa('LEVEL_2')
      get :index, params: { locale: 'en' }
      expect(a_request_to_piwik).to have_been_made
      expect(subject).to render_template(:start)
    end

    context 'when form is valid' do
      it 'will redirect to sign in page when selection is false' do
        set_session_and_cookies_with_loa('LEVEL_2')
        post :request_post, params: { locale: 'en', start_form: { selection: false } }
        expect(subject).to redirect_to('/sign-in')
      end

      it 'will redirect to about page when selection is true' do
        set_session_and_cookies_with_loa('LEVEL_2')
        post :request_post, params: { locale: 'en', start_form: { selection: true } }
        expect(subject).to redirect_to('/about')
      end
    end

    context 'when form is invalid' do
      it 'renders itself' do
        set_session_and_cookies_with_loa('LEVEL_2')
        post :request_post, params: { locale: 'en' }
        expect(subject).to render_template(:start)
        expect(flash[:errors]).not_to be_empty
      end
    end
  end

  context 'LOA1' do
    it 'renders LOA1 start page if service is level 1' do
      set_session_and_cookies_with_loa('LEVEL_1')
      stub_piwik_report_loa_requested('LEVEL_1')
      get :index, params: { locale: 'en' }
      expect(subject).to render_template(:start_loa1)
    end
  end
end
