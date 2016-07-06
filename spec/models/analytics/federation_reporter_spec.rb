require 'spec_helper'
require 'models/analytics/federation_reporter'
require 'analytics'
require 'models/display/federation_translator'
require 'logger_helper'

module Analytics
  describe FederationReporter do
    let(:federation_translator) { double(:federation_translator) }
    let(:analytics_reporter) { double(:analytics_reporter) }
    let(:federation_reporter) { FederationReporter.new(federation_translator, analytics_reporter) }
    let(:request) { double(:request) }

    describe '#report_sign_in_idp_selection' do
      it 'should build correct report' do
        idp_display_name = 'IDCorp'
        expect(analytics_reporter).to receive(:report_custom_variable)
          .with(
            request,
            "Sign In - #{idp_display_name}",
            3 => ['SIGNIN_IDP', idp_display_name]
          )

        federation_reporter.report_sign_in_idp_selection(request, idp_display_name)
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
            2 => ['REGISTER_IDP', idp_name],
            5 => ['IDP_SELECTION', idp_history_str]
          )
        federation_reporter.report_idp_registration(request, idp_name, idp_history, %w(passport), true)
      end

      it 'should report correctly if IdP was not recommended' do
        expect(analytics_reporter).to receive(:report_custom_variable)
          .with(
            request,
            "#{idp_name} was chosen for registration (not recommended) with evidence passport",
            2 => ['REGISTER_IDP', idp_name],
            5 => ['IDP_SELECTION', idp_history_str]
          )
        federation_reporter.report_idp_registration(request, idp_name, idp_history, %w(passport), false)
      end

      it 'should sort evidence' do
        expect(analytics_reporter).to receive(:report_custom_variable)
          .with(
            request,
            "#{idp_name} was chosen for registration (recommended) with evidence driving_licence, passport",
            2 => ['REGISTER_IDP', idp_name],
            5 => ['IDP_SELECTION', idp_history_str]
          )
        federation_reporter.report_idp_registration(request, idp_name, idp_history, %w(passport driving_licence), true)
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
        simple_id = 'id'
        description = 'description'
        allow(federation_translator).to receive(:translate)
                                          .with('rps.id.analytics_description')
                                          .and_return(description)
        expect(analytics_reporter).to receive(:report_custom_variable)
                                        .with(
                                          request,
                                          'Matching Outcome - Cancelled Cycle3',
                                          1 => %w[RP description]
                                        )
        federation_reporter.report_cycle_three_cancel(simple_id, request)
      end
    end

    it 'should report custom variable for sign in' do
      simple_id = 'id'
      description = 'description'
      allow(federation_translator).to receive(:translate)
        .with('rps.id.analytics_description')
        .and_return(description)
      expect(analytics_reporter).to receive(:report_custom_variable)
        .with(
          request,
          'The No option was selected on the introduction page',
          1 => %w[RP description]
        )

      federation_reporter.report_sign_in(simple_id, request)
    end

    it 'should report custom variable for registration' do
      simple_id = 'id'
      description = 'description'
      allow(federation_translator).to receive(:translate)
        .with('rps.id.analytics_description')
        .and_return(description)
      expect(analytics_reporter).to receive(:report_custom_variable)
        .with(
          request,
          'The Yes option was selected on the start page',
          1 => %w[RP description]
        )

      federation_reporter.report_registration(simple_id, request)
    end

    it 'should not report custom variable if transaction analytics description is not available' do
      translation_error = Display::FederationTranslator::TranslationError.new
      allow(federation_translator).to receive(:translate)
        .with('rps.id.analytics_description')
        .and_raise(translation_error)
      expect(stub_logger).to receive(:warn).with(translation_error).at_least(:once)
      allow(analytics_reporter).to receive(:report_custom_variable)

      federation_reporter.report_sign_in('id', request)

      expect(analytics_reporter).to_not have_received(:report_custom_variable)
    end
  end
end
