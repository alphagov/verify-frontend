require 'spec_helper'
require 'models/ab_test/ab_test'
require 'models/ab_test/experiment'

module AbTest
  describe AbTest do
    context '#alternative_name_for_experiment' do
      it 'should return the default when no experiment exists' do
        ::AB_TESTS = {}.freeze
        alternative_name = subject.alternative_name_for_experiment('missing_experiment', 'alternative', 'default')
        expect(alternative_name).to eq('default')
      end

      it 'should return alternative name' do
        alternatives = { 'logos' => { 'alternatives' => [{ 'name' => 'yes', 'percent' => 75 }] } }
        ::AB_TESTS = { 'logos' => Experiment.new(alternatives) }.freeze
        alternative_name = subject.alternative_name_for_experiment('logos', 'logos_yes', 'default')
        expect(alternative_name).to eq('logos_yes')
      end

      it 'should return first alternative name when given invalid alternative' do
        alternatives = { 'logos' => { 'alternatives' => [{ 'name' => 'yes', 'percent' => 75 }] } }
        ::AB_TESTS = { 'logos' => Experiment.new(alternatives) }.freeze
        alternative_name = subject.alternative_name_for_experiment('logos', 'invalid', 'default')
        expect(alternative_name).to eq('logos_yes')
      end
    end
  end
end
