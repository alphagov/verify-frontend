require 'rails_helper'
require 'controller_helper'
require 'spec_helper'
require 'models/display/viewable_identity_provider'

describe ConfirmationLoa1Controller do
  subject { get :index, params: { locale: 'en' } }

  context 'user has selected an idp' do
    before(:each) do
      set_selected_idp('entity_id' => 'http://idcorp.com', 'simple_id' => 'stub-idp-one', 'levels_of_assurance' => %w(LEVEL_1 LEVEL_2))
    end

    it 'renders the confirmation LOA1 template when LEVEL_1 is the requested LOA' do
      set_session_and_cookies_with_loa('LEVEL_1')
      expect(subject).to render_template(:confirmation_LOA1)
    end
  end

  context 'user has no selected IDP in session' do
    it 'should raise a WarningLevelError' do
      set_session_and_cookies_with_loa('LEVEL_1')
      expect(Rails.logger).to receive(:warn).with(kind_of(Errors::WarningLevelError)).once
      get :index, params: { locale: 'en' }
      expect(response).to have_http_status(500)
    end
  end
end
