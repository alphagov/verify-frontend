require 'spec_helper'
require 'idp_eligibility/profile_filter'
require 'idp_eligibility/profile'

module IdpEligibility
  describe ProfileFilter do
    describe '#idps_for_profile' do
      it 'should return idps that meet a profile' do
        rules_hash = { 'example-idp' => [Profile.new(%i(passport driving_licence))] }
        repository = ProfileFilter.new(rules_hash)
        expect(repository.idps_for(%i{passport driving_licence})).to eql(['example-idp'])
      end

      it 'should not return idps don\'t meet a profile' do
        rules_hash = { 'example-idp' => [Profile.new(%i(driving_licence passport mobile_phone))] }
        repository = ProfileFilter.new(rules_hash)
        expect(repository.idps_for(%i{passport driving_licence})).to eql([])
      end

      it 'should return idps that meet a profile that implement many profiles' do
        rules_hash = { 'example-idp' => [Profile.new(%i(driving_licence passport)), Profile.new(%i{mobile_phone})] }
        repository = ProfileFilter.new(rules_hash)
        expect(repository.idps_for(%i{passport driving_licence})).to eql(['example-idp'])
      end
    end
  end
end
