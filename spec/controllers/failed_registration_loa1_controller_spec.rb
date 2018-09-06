require 'rails_helper'
require 'controller_helper'
require 'spec_helper'
require 'api_test_helper'

describe FailedRegistrationLoa1Controller do
  A_CONTINUE_ON_FAILED_REGISTRATION_RP = 'test-rp-with-continue-on-fail'.freeze
  A_NON_CONTINUE_ON_FAILED_REGISTRATION_RP = 'test-rp'.freeze

  before(:each) do
    set_selected_idp('entity_id' => 'http://idcorp.com', 'simple_id' => 'stub-idp-one', 'levels_of_assurance' => %w(LEVEL_1 LEVEL_2))
    session[:selected_idp_was_recommended] = false
  end

  subject { get :index, params: { locale: 'en' } }

  context 'renders LOA1' do
    before :each do
      set_session_and_cookies_with_loa('LEVEL_1')
    end

    it 'index view when rp is not allowed to continue on failed' do
      set_rp_to(A_NON_CONTINUE_ON_FAILED_REGISTRATION_RP)
      expect(subject).to render_template(:index_LOA1)
    end

    it 'continue on failed registration view when rp is allowed to continue on failed' do
      set_rp_to(A_CONTINUE_ON_FAILED_REGISTRATION_RP)

      expect(subject).to render_template(:index_continue_on_failed_registration_LOA1)
    end
  end

  def set_rp_to(relying_party)
    session[:transaction_simple_id] = relying_party
  end
end
