require 'idp_eligibility/profile_filter'
require 'idp_eligibility/recommendation_grouper'
require 'idp_eligibility/profile'
require 'set'

module IdpEligibility
  describe RecommendationGrouper do
    let(:idp_one) { double(:idp_one, simple_id: 'idp') }
    let(:idp_two) { double(:idp_one, simple_id: 'idp2') }
    let(:singleton_idp) { [idp_one].to_set }
    let(:transaction_simple_id) { 'a-transaction' }
    let(:blacklisted_transaction_simple_id) { 'blacklisted-transaction' }
    let(:passport_profile) { Profile.new([:passport]) }
    let(:driving_licence_profile) { Profile.new([:driving_licence]) }
    let(:passport_and_driving_licence_profile) { Profile.new(%i[driving_licence passport]) }
    let(:demo_profile) { Profile.new(%i[mobile_phone driving_licence]) }
    let(:recommended_profile_filter) { ProfileFilter.new('idp' => [passport_profile, passport_and_driving_licence_profile]) }
    let(:non_recommended_profile_filter) { ProfileFilter.new('idp' => [driving_licence_profile], 'idp2' => [passport_profile, passport_and_driving_licence_profile]) }
    let(:demo_profile_filter) { ProfileFilter.new('idp' => [demo_profile]) }
    let(:transaction_blacklist) { [blacklisted_transaction_simple_id] }
    let(:grouper) { RecommendationGrouper.new(recommended_profile_filter, non_recommended_profile_filter, demo_profile_filter, transaction_blacklist) }

    describe '#recommended?' do
      it 'should return false when idp cannot verify with evidence' do
        enabled_idps = singleton_idp
        user_docs = [:driving_licence]

        expect(grouper.recommended?(idp_one, user_docs, enabled_idps, transaction_simple_id)).to eql(false)
      end

      it 'should return true when idp can verify with evidence' do
        enabled_idps = singleton_idp
        user_docs = [:passport]

        expect(grouper.recommended?(idp_one, user_docs, enabled_idps, transaction_simple_id)).to eql(true)
      end

      it 'should return true when profile is in IDP demo profiles' do
        enabled_idps = singleton_idp
        user_docs = %i[mobile_phone driving_licence]
        expect(grouper.recommended?(idp_one, user_docs, enabled_idps, transaction_simple_id)).to eql(true)
      end

      it 'should return false when profile is in IdP demo profiles but the transaction does not allow demos' do
        enabled_idps = singleton_idp
        user_docs = %i[mobile_phone driving_licence]
        expect(grouper.recommended?(idp_one, user_docs, enabled_idps, blacklisted_transaction_simple_id)).to eql(false)
      end
    end

    describe '#group_by_recommendation' do
      let(:multiple_idps) { [idp_one, idp_two] }

      it 'should return recommended idps' do
        user_docs = [:passport]
        grouped_idps = grouper.group_by_recommendation(user_docs, singleton_idp, transaction_simple_id)
        expect(grouped_idps.recommended).to eql(singleton_idp)
        expect(grouped_idps.non_recommended).to eql(Set.new)
      end

      it 'should return non-recommended idps' do
        enabled_idps = multiple_idps
        user_docs = [:driving_licence]
        grouped_idps = grouper.group_by_recommendation(user_docs, enabled_idps, transaction_simple_id)
        expect(grouped_idps.recommended).to eql(Set.new)
        expect(grouped_idps.non_recommended).to eql(singleton_idp)
      end

      it 'should return recommended and non-recommended idps' do
        enabled_idps = multiple_idps
        user_docs = %i[passport driving_licence]
        grouped_idps = grouper.group_by_recommendation(user_docs, enabled_idps, transaction_simple_id)
        expect(grouped_idps.recommended).to eql([idp_one].to_set)
        expect(grouped_idps.non_recommended).to eql([idp_two].to_set)
      end

      it 'should return an empty list when no enabled idps' do
        enabled_idps = []
        user_docs = [:passport]
        grouped_idps = grouper.group_by_recommendation(user_docs, enabled_idps, transaction_simple_id)
        expect(grouped_idps.recommended).to eql([].to_set)
        expect(grouped_idps.non_recommended).to eql([].to_set)
      end

      it 'should add demo profiles to recommended' do
        enabled_idps = singleton_idp
        user_docs = %i[driving_licence mobile_phone]
        grouped_idps = grouper.group_by_recommendation(user_docs, enabled_idps, transaction_simple_id)
        expect(grouped_idps.recommended).to eql([idp_one].to_set)
        expect(grouped_idps.non_recommended).to be_empty
      end

      it 'should not add demo profiles to recommended when rp is blacklisted' do
        enabled_idps = singleton_idp
        user_docs = %i[driving_licence mobile_phone]
        grouped_idps = grouper.group_by_recommendation(user_docs, enabled_idps, blacklisted_transaction_simple_id)
        expect(grouped_idps.non_recommended).to eql([idp_one].to_set)
        expect(grouped_idps.recommended).to be_empty
      end
    end
  end
end
