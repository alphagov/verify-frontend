require 'spec_helper'
require 'idp_eligibility/profile_filter'
require 'idp_eligibility/profile'

module IdpEligibility
  describe ProfileFilter do
    describe "#filter_idps_for" do
      it 'will returns idps that meet evidence using their simple id' do
        idp_one = double(:idp_one, simple_id: 'idp_one')
        idp_two = double(:idp_two, simple_id: 'idp_two')
        profiles_hash = { 'idp_one' => [Profile.new(%i(driving_licence passport)), Profile.new(%i{mobile_phone})] }
        enabled_idps = [idp_one, idp_two]
        evidence = %i{passport driving_licence}
        filtered_idps = ProfileFilter.new(profiles_hash).filter_idps_for(evidence, enabled_idps)
        expect(filtered_idps).to eql [idp_one].to_set
      end

      it 'will only return an idp once even if it matching profiles multiple times' do
        idp_one = double(:idp_one, simple_id: 'idp_one')
        idp_two = double(:idp_two, simple_id: 'idp_two')
        profiles_hash = { 'idp_one' => [Profile.new(%i(driving_licence passport)), Profile.new(%i(driving_licence passport))] }
        enabled_idps = [idp_one, idp_two]
        evidence = %i{passport driving_licence}
        filtered_idps = ProfileFilter.new(profiles_hash).filter_idps_for(evidence, enabled_idps)
        expect(filtered_idps).to eql [idp_one].to_set
      end

      it 'will not returns idps that do not meet evidence using their simple id' do
        idp_one = double(:idp_one, simple_id: 'idp_one')
        idp_two = double(:idp_two, simple_id: 'idp_two')
        profiles_hash = { 'idp_one' => [Profile.new(%i(driving_licence passport)), Profile.new(%i{mobile_phone})] }
        enabled_idps = [idp_one, idp_two]
        evidence = %i{landline_phone non_uk_id_document}
        filtered_idps = ProfileFilter.new(profiles_hash).filter_idps_for(evidence, enabled_idps)
        expect(filtered_idps).to be_empty
      end
    end
  end
end
