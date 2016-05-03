require 'spec_helper'
require 'idp_eligibility/rules_repository'

module IdpEligibility
  describe RulesRepository do
    describe '#idps_for_profile' do
      it 'should return idps that meet a profile' do
        rules_hash = { 'example-idp' => [%i(passport driving_licence)] }
        repository = RulesRepository.new(rules_hash)
        expect(repository.idps_for_profile(%i{passport driving_licence})).to eql(['example-idp'])
      end

      it 'should not return idps don\'t meet a profile' do
        rules_hash = { 'example-idp' => [%i(driving_licence passport mobile_phone)] }
        repository = RulesRepository.new(rules_hash)
        expect(repository.idps_for_profile(%i{passport driving_licence})).to eql([])
      end

      it 'should return idps that meet a profile that implement many profiles' do
        rules_hash = { 'example-idp' => [%i(driving_licence passport), %i{mobile_phone}] }
        repository = RulesRepository.new(rules_hash)
        expect(repository.idps_for_profile(%i{passport driving_licence})).to eql(['example-idp'])
      end
    end
  end
end
