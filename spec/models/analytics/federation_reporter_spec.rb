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

    it 'should report custom variable for idp selection' do
      idp_names = %w(A B C D)
      expect(analytics_reporter).to receive(:report_custom_variable)
        .with(
          request,
          'IDP selection',
          5 => %w[IDP_SELECTION A,B,C,D]
        )
      federation_reporter.report_idp_selection(idp_names, request)
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
