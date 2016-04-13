require 'spec_helper'
require 'models/display/rp/repository'

module Display
  module Rp
    describe 'Repository' do
      it 'should get other ways data given a simple_id' do
        translator = double(:translator)
        allow(translator).to receive(:translate).with('rps.test-rp.otherWaysDescription').and_return('Other ways description')
        allow(translator).to receive(:translate).with('rps.test-rp.otherWaysText').and_return('Other ways text')
        repository = Repository.new(translator)

        result = repository.fetch('test-rp')

        expect(result.other_ways_description).to eql('Other ways description')
        expect(result.other_ways_text).to eql('Other ways text')
      end
    end
  end
end
