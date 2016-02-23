require 'models/display/idp/display_data_correlator'
require 'models/display/federation_translator'

module Display
  module Idp
    describe DisplayDataCorrelator do
      it 'takes a list of IDP data and a translator with knowledge of IDPs and returns a list of IDPs to display' do
        translator = double(:translator)
        correlator = DisplayDataCorrelator.new(translator)

        idp_list = [{'simpleId' => 'test-simple-id', 'entityId' => 'test-entity-id'}]
        expect(translator).to receive(:translate).with('idps.test-simple-id.name').and_return('Test Display Name')
        result = correlator.correlate(idp_list)
        expected_result = [DisplayData.new('test-entity-id', 'Test Display Name')]
        expect(result).to eql expected_result
      end

      it "will skip IDP if translations can't be found" do
        translation_error = Display::FederationTranslator::TranslationError.new
        logger = double(:logger)
        rails_double = double(:rails, logger: logger)
        stub_const('Rails', rails_double)
        expect(logger).to receive(:error).with(translation_error).at_least(:once)

        translator = double(:translator)
        correlator = DisplayDataCorrelator.new(translator)

        allow(translator).to receive(:translate).with('idps.test-simple-id.name').and_raise(translation_error)
        idp_list = [{'simpleId' => 'test-simple-id', 'entityId' => 'test-entity-id'}]
        result = correlator.correlate(idp_list)
        expect(result).to eql []
      end
    end
  end
end
