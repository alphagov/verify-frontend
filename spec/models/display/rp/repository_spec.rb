require 'spec_helper'
require 'models/display/rp/repository'

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
        repository = Repository.new(translator)

        result = repository.fetch('test-rp')

        expect(result.other_ways_description).to eql('Other ways description')
        expect(result.other_ways_text).to eql('Other ways text')
        expect(result.name).to eql('Display name')
      end
    end
  end
end
