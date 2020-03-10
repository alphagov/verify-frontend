require 'rails_helper'
require 'controller_helper'
require 'spec_helper'
require 'api_test_helper'

describe FailedRegistrationLoa1Controller do
  WITH_CONTINUE_ON_FAILED_REGISTRATION_RP = 'test-rp-with-continue-on-fail'.freeze
  WITH_NON_CONTINUE_ON_FAILED_REGISTRATION_RP = 'test-rp'.freeze
  render_views

  let(:stub_idp_one) {
    {
        'simpleId' => 'stub-idp-one',
        'entityId' => 'http://idcorp-one.com',
        'levelsOfAssurance' => %w(LEVEL_1 LEVEL_2)
    }.freeze
  }

  let(:stub_idp_two) {
    {
        'simpleId' => 'stub-idp-two',
        'entityId' => 'http://idcorp-two.com',
        'levelsOfAssurance' => %w(LEVEL_1)
    }.freeze
  }

  let(:stub_idp_three) {
    {
        'simpleId' => 'stub-idp-three',
        'entityId' => 'http://idcorp-three.com',
        'levelsOfAssurance' => %w(LEVEL_1)
    }.freeze
  }

  let(:idp_recommendation_engine) { double(:idp_recommendation_engine) }

  before(:each) do
    stub_const('IDP_RECOMMENDATION_ENGINE', idp_recommendation_engine)
    set_selected_idp('entity_id' => 'http://idcorp.com', 'simple_id' => 'stub-idp-one', 'levels_of_assurance' => %w(LEVEL_1 LEVEL_2))
    session[:selected_idp_was_recommended] = true
  end

  subject { get :index, params: { locale: 'en' } }

  context 'renders LOA1' do
    before :each do
      set_session_and_cookies_with_loa('LEVEL_1')
    end
    context 'two IDPs' do
      before :each do
        allow(idp_recommendation_engine).to receive(:get_suggested_idps).and_return(recommended: [IdentityProvider.new(stub_idp_two), IdentityProvider.new(stub_idp_one)])
        stub_api_idp_list_for_loa([stub_idp_one, stub_idp_two], 'LEVEL_1')
      end

      it 'index view when rp is not allowed to continue on failed' do
        set_rp_to(WITH_NON_CONTINUE_ON_FAILED_REGISTRATION_RP)

        expect(subject).to render_template(:index_LOA1)
        expect(subject).to render_template(partial: '_non_continue_rp_two_idp')
      end

      it 'continue on failed registration view when rp is allowed to continue on failed' do
        set_rp_to(WITH_CONTINUE_ON_FAILED_REGISTRATION_RP)

        expect(subject).to render_template(:index_continue_on_failed_registration_LOA1)
        expect(subject).to render_template(partial: '_continue_rp_two_idp')
      end
    end

    context 'three IDPs' do
      before :each do
        allow(idp_recommendation_engine).to receive(:get_suggested_idps).and_return(recommended: [IdentityProvider.new(stub_idp_three), IdentityProvider.new(stub_idp_two), IdentityProvider.new(stub_idp_one)])
        stub_api_idp_list_for_loa([stub_idp_one, stub_idp_two, stub_idp_three], 'LEVEL_1')
      end
      it 'index view when rp is not allowed to continue on failed' do
        set_rp_to(WITH_NON_CONTINUE_ON_FAILED_REGISTRATION_RP)

        expect(subject).to render_template(:index_LOA1)
        expect(subject).to render_template(partial: '_non_continue_rp')
      end

      it 'continue on failed registration view when rp is allowed to continue on failed' do
        set_rp_to(WITH_CONTINUE_ON_FAILED_REGISTRATION_RP)

        expect(subject).to render_template(:index_continue_on_failed_registration_LOA1)
        expect(subject).to render_template(partial: '_continue_rp')
      end
    end
  end

  def set_rp_to(relying_party)
    session[:transaction_simple_id] = relying_party
  end
end
