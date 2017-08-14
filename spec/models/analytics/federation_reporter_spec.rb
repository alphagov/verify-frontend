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

    describe '#report_sign_in_idp_selection' do
      it 'should build correct report' do
        idp_display_name = 'IDCorp'
        expect(analytics_reporter).to receive(:report)
          .with(
            request,
            "Sign In - #{idp_display_name}"
          )

        federation_reporter.report_sign_in_idp_selection(request, idp_display_name)
      end
    end

    describe '#report_loa_requested' do
      it 'should report the LOA of the transaction' do
        requested_loa = 'LEVEL_1'
        expect(analytics_reporter).to receive(:report_custom_variable)
        .with(
          request,
          "LOA Requested - #{requested_loa}",
          2 => ['LOA_REQUESTED', requested_loa]
        )
        federation_reporter.report_loa_requested(request, requested_loa)
      end
    end

    describe '#report_idp_registration' do
      idp_name = 'IDCorp'
      idp_history = ['Previous IdP', 'IDCorp']
      idp_history_str = idp_history.join(',')

      it 'should report correctly if IdP was recommended' do
        expect(analytics_reporter).to receive(:report_custom_variable)
        .with(
          request,
          "#{idp_name} was chosen for registration (recommended) with evidence passport",
          5 => ['IDP_SELECTION', idp_history_str]
        )
        federation_reporter.report_idp_registration(request, idp_name, idp_history, %w(passport), '(recommended)')
      end

      it 'should report correctly if IdP was not recommended' do
        expect(analytics_reporter).to receive(:report_custom_variable)
          .with(
            request,
            "#{idp_name} was chosen for registration (not recommended) with evidence passport",
            5 => ['IDP_SELECTION', idp_history_str]
          )
        federation_reporter.report_idp_registration(request, idp_name, idp_history, %w(passport), '(not recommended)')
      end

      it 'should report correctly if IdP recommendation key not found in session' do
        expect(analytics_reporter).to receive(:report_custom_variable)
          .with(
            request,
            "#{idp_name} was chosen for registration (idp recommendation key not set) with evidence passport",
            5 => ['IDP_SELECTION', idp_history_str]
            )
        federation_reporter.report_idp_registration(request, idp_name, idp_history, %w(passport), '(idp recommendation key not set)')
      end

      it 'should sort evidence' do
        expect(analytics_reporter).to receive(:report_custom_variable)
          .with(
            request,
            "#{idp_name} was chosen for registration (recommended) with evidence driving_licence, passport",
            5 => ['IDP_SELECTION', idp_history_str]
          )
        federation_reporter.report_idp_registration(request, idp_name, idp_history, %w(passport driving_licence), '(recommended)')
      end
    end

    describe '#report_cycle_three' do
      it 'should report cycle 3 attribute name' do
        attribute_name = 'anAttribute'
        expect(analytics_reporter).to receive(:report_custom_variable)
                                        .with(
                                          request,
                                          'Cycle3 submitted',
                                          4 => ['CYCLE_3', attribute_name]
                                        )
        federation_reporter.report_cycle_three(request, attribute_name)
      end
    end

    describe '#report_cycle_three_cancel' do
      it 'should report cycle 3 cancelled' do
        current_transaction = double("current transaction")
        description = 'description'
        expect(current_transaction).to receive(:analytics_description)
                                          .and_return(description)
        expect(analytics_reporter).to receive(:report_custom_variable)
                                        .with(
                                          request,
                                          'Matching Outcome - Cancelled Cycle3',
                                          1 => %w[RP description]
                                        )
        federation_reporter.report_cycle_three_cancel(current_transaction, request)
      end
    end

    it 'should report custom variable for sign in' do
      current_transaction = double("current transaction")
      description = 'description'
      expect(current_transaction).to receive(:analytics_description).and_return(description)
      expect(analytics_reporter).to receive(:report_custom_variable)
        .with(
          request,
          'The No option was selected on the introduction page',
          1 => %w[RP description]
        )

      federation_reporter.report_sign_in(current_transaction, request)
    end

    it 'should report custom variable for registration' do
      current_transaction = double("current transaction")
      description = 'description'
      expect(current_transaction).to receive(:analytics_description).and_return(description)
      expect(analytics_reporter).to receive(:report_custom_variable)
        .with(
          request,
          'The Yes option was selected on the start page',
          1 => %w[RP description]
        )

      federation_reporter.report_registration(current_transaction, request)
    end
  end
end
