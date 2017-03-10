require 'rspec'
require 'rails_helper'
require 'journeys'

describe 'Journeys' do
  context '.get_path' do
    it 'should return the next path given some symbol' do
      journeys = Journeys.new do
        at '/current_path', next: '/next_path'
      end
      next_path = journeys.get_path('/current_path')
      expect(next_path).to eql('/next_path')
    end

    it 'should raise an error if given a non-existent path' do
      journeys = Journeys.new do
        at '/current_path', next: '/next_path'
      end
      expect { journeys.get_path('/made_up_thing') }
        .to raise_error('Path not found: /made_up_thing')
    end
  end
end
