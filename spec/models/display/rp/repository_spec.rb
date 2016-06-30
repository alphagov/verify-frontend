require 'spec_helper'
require 'models/display/rp/repository'
require 'rails_helper'

module Display
  module Rp
    describe 'Repository' do
      it 'should error if simple_id is nil' do
        translator = double(:translator)
        repository = Repository.new(translator)
        expect { repository.fetch(nil) }.to raise_error StandardError, 'No transaction simple id in session'
      end

      it 'should get other ways data given a simple_id' do
        translator = double(:translator)
        allow(translator).to receive(:translate).with('rps.test-rp.other_ways_description').and_return('Other ways description')
        allow(translator).to receive(:translate).with('rps.test-rp.other_ways_text').and_return('Other ways text')
        allow(translator).to receive(:translate).with('rps.test-rp.name').and_return('Display name')
        allow(translator).to receive(:translate).with('rps.test-rp.rp_name').and_return('Test RP')
        repository = Repository.new(translator)

        result = repository.fetch('test-rp')

        expect(result.other_ways_description).to eql('Other ways description')
        expect(result.other_ways_text).to eql('Other ways text')
        expect(result.name).to eql('Display name')
        expect(result.rp_name).to eql('Test RP')
      end

      it 'should have additional translations if allowed to continue on failed registration' do
        translator = double(:translator)
        allow(translator).to receive(:translate).with('rps.test-rp.other_ways_description').and_return('Other ways description')
        allow(translator).to receive(:translate).with('rps.test-rp.other_ways_text').and_return('Other ways text')
        allow(translator).to receive(:translate).with('rps.test-rp.name').and_return('Display name')
        allow(translator).to receive(:translate).with('rps.test-rp.rp_name').and_return('Test RP')
        allow(translator).to receive(:translate).with('rps.test-rp.failed_registration_header').and_return('Continue anyway')
        allow(translator).to receive(:translate).with('rps.test-rp.failed_registration_body').and_return('Do some stuff')
        allow(CONTINUE_ON_FAILED_REGISTRATION_RPS).to receive(:include?).with('test-rp').and_return(true)
        repository = Repository.new(translator)

        result = repository.fetch('test-rp')

        expect(result.failed_registration_header).to eql('Continue anyway')
        expect(result.failed_registration_body).to eql('Do some stuff')
      end
    end
  end
end
