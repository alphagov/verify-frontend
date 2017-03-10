require 'rspec'
require 'rails_helper'
require 'journeys'

describe 'Journeys' do
  context 'linear journey' do
    it 'should return the next path given some symbol' do
      journeys = Journeys.new do
        at '/current-path', next: '/next-path'
      end
      next_path = journeys.get_path('/current-path')
      expect(next_path).to eql('/next-path')
    end

    it 'should raise an error if given a non-existent path' do
      journeys = Journeys.new do
        at '/current-path', next: '/next-path'
      end
      expect { journeys.get_path('/made-up-thing') }
        .to raise_error('Path not found: /made-up-thing')
    end
  end
  context 'branching journey' do
    it 'should return correct path depending on conditions' do
      journey = Journeys.new do
        branch_at '/current-path',
          [:some_condition] => '/branching-path',
          [:another_condition] => '/default-path'
      end
      expect(journey.get_path('/current-path', [:some_condition]))
        .to eql('/branching-path')
    end

    it 'should raise error when no conditions match' do
      journey = Journeys.new do
        branch_at '/current-path',
          [:some_condition] => '/branching-path',
          [:another_condition] => '/default-path'
      end
      expect { journey.get_path('/current-path', []) }
        .to raise_error('No matching conditions on path /current-path for []')
    end
  end
end
