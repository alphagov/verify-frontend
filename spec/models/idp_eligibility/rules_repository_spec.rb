require 'spec_helper'
require 'models/idp_eligibility/rules_repository'

module IdpEligibility
  describe RulesRepository do
    describe '#initialize' do
      it 'should convert idp rules to symbols' do
        rules_hash = { 'example-idp' => [%w(passport driving_licence)] }
        repository = RulesRepository.new(rules_hash)
        expect(repository.rules).to eql('example-idp' => [[:passport, :driving_licence].to_set].to_set)
      end
    end
  end
end
