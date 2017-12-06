require 'spec_helper'
require 'models/analytics/federation_reporter'
require 'analytics'
require 'logger_helper'
require 'models/errors/warning_level_error'

module Analytics
  describe FederationReporter do
    let(:analytics_reporter) { double(:analytics_reporter) }
    let(:federation_reporter) { FederationReporter.new(analytics_reporter) }
    let(:request) { double(:request) }
    let(:current_transaction) { double('current transaction') }
    let(:transaction_description) { 'description' }

    before(:each) do
      allow(request).to receive(:session).and_return(requested_loa: 'LEVEL_2')
      allow(current_transaction).to receive(:analytics_description).and_return(transaction_description)
    end

    describe '#report_sign_in_idp_selection' do
      it 'should build correct report' do
        idp_display_name = 'IDCorp'
        expect(analytics_reporter).to receive(:report_action)
          .with(
            request,
            "Sign In - #{idp_display_name}",
            1 => %w(RP description),
            2 => %w(LOA_REQUESTED LEVEL_2),
          )

        federation_reporter.report_sign_in_idp_selection(current_transaction, request, idp_display_name)
      end
    end

    describe '#report_idp_registration' do
      idp_name = 'IDCorp'
      idp_history = ['Previous IdP', 'IDCorp']
      idp_history_str = idp_history.join(',')

      it 'should report correctly if IdP was recommended' do
        expect(analytics_reporter).to receive(:report_action)
          .with(
            request,
            "#{idp_name} was chosen for registration (recommended) with segment(s) segment1 and evidence passport",
            1 => %w(RP description),
            2 => %w(LOA_REQUESTED LEVEL_2),
            5 => ['IDP_SELECTION', idp_history_str]
          )
        federation_reporter.report_idp_registration(
          current_transaction: current_transaction,
          request: request,
          idp_name: idp_name,
          idp_name_history: idp_history,
          evidence: %w(passport),
          recommended: '(recommended)',
          user_segments: %w(segment1)
        )
      end

      it 'should report correctly if IdP was not recommended' do
        expect(analytics_reporter).to receive(:report_action)
          .with(
            request,
            "#{idp_name} was chosen for registration (not recommended) with segment(s) segment1 and evidence passport",
            1 => %w(RP description),
            2 => %w(LOA_REQUESTED LEVEL_2),
            5 => ['IDP_SELECTION', idp_history_str]
          )
        federation_reporter.report_idp_registration(
          current_transaction: current_transaction,
          request: request,
          idp_name: idp_name,
          idp_name_history: idp_history,
          evidence: %w(passport),
          recommended: '(not recommended)',
          user_segments: %w(segment1)
        )
      end

      it 'should report correctly if IdP recommendation key not found in session' do
        expect(analytics_reporter).to receive(:report_action)
          .with(
            request,
            "#{idp_name} was chosen for registration (idp recommendation key not set) with segment(s) segment1 and evidence passport",
            1 => %w(RP description),
            2 => %w(LOA_REQUESTED LEVEL_2),
            5 => ['IDP_SELECTION', idp_history_str]
          )
        federation_reporter.report_idp_registration(
          current_transaction: current_transaction,
          request: request,
          idp_name: idp_name,
          idp_name_history: idp_history,
          evidence: %w(passport),
          recommended: '(idp recommendation key not set)',
          user_segments: %w(segment1)
        )
      end

      it 'should sort evidence' do
        expect(analytics_reporter).to receive(:report_action)
          .with(
            request,
            "#{idp_name} was chosen for registration (recommended) with segment(s) segment1, segment2 and evidence driving_licence, passport",
            1 => %w(RP description),
            2 => %w(LOA_REQUESTED LEVEL_2),
            5 => ['IDP_SELECTION', idp_history_str]
          )
        federation_reporter.report_idp_registration(
          current_transaction: current_transaction,
          request: request,
          idp_name: idp_name,
          idp_name_history: idp_history,
          evidence: %w(passport driving_licence),
          recommended: '(recommended)',
          user_segments: %w(segment1 segment2)
        )
      end
    end

    describe '#report_ab_test' do
      before(:each) do
        RP_DISPLAY_REPOSITORY = double
        transaction = double
        allow(transaction).to receive(:analytics_description).and_return('description')
        allow(RP_DISPLAY_REPOSITORY).to receive(:fetch).with('test-rp').and_return(transaction)
      end

      it 'should report an ab test custom variable' do
        alternative_name = 'alternative_name'
        expect(analytics_reporter).to receive(:report_action)
          .with(
            request,
            'The user has started an AB test',
            1 => %w(RP description),
            2 => %w(LOA_REQUESTED LEVEL_2),
            6 => ['AB_TEST', alternative_name]
          )
        federation_reporter.report_ab_test('test-rp', request, alternative_name)
      end
    end

    describe '#report_cycle_three' do
      it 'should report cycle 3 attribute name' do
        attribute_name = 'anAttribute'
        expect(analytics_reporter).to receive(:report_action)
          .with(
            request,
            'Cycle3 submitted',
            1 => %w(RP description),
            2 => %w(LOA_REQUESTED LEVEL_2),
            4 => ['CYCLE_3', attribute_name]
          )
        federation_reporter.report_cycle_three(current_transaction, request, attribute_name)
      end
    end

    describe '#report_cycle_three_cancel' do
      it 'should report cycle 3 cancelled' do
        expect(analytics_reporter).to receive(:report_action)
          .with(
            request,
            'Matching Outcome - Cancelled Cycle3',
            1 => %w(RP description),
            2 => %w(LOA_REQUESTED LEVEL_2),
          )
        federation_reporter.report_cycle_three_cancel(current_transaction, request)
      end
    end

    describe '#report_sign_in' do
      it 'should report sign in journey' do
        expect(analytics_reporter).to receive(:report_action)
          .with(
            request,
            'The user started a sign-in journey',
            1 => %w(RP description),
            2 => %w(LOA_REQUESTED LEVEL_2),
            3 => %w(JOURNEY_TYPE SIGN_IN)
          )

        federation_reporter.report_sign_in(current_transaction, request)
      end
    end

    describe '#report_registration' do
      it 'should report registration journey' do
        expect(analytics_reporter).to receive(:report_action)
          .with(
            request,
            'The user started a registration journey',
            1 => %w(RP description),
            2 => %w(LOA_REQUESTED LEVEL_2),
            3 => %w(JOURNEY_TYPE REGISTRATION)
          )

        federation_reporter.report_registration(current_transaction, request)
      end
    end

    describe '#report_number_of_idps_recommended' do
      it 'should report the number of IDPs that were recommended' do
        expect(analytics_reporter).to receive(:report_event)
          .with(
            request,
            {
              1 => %w(RP description),
              2 => %w(LOA_REQUESTED LEVEL_2)
            },
            'Engagement',
            'IDPs Recommended',
            5
          )

        federation_reporter.report_number_of_idps_recommended(current_transaction, request, 5)
      end
    end
  end
end
