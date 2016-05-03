require 'models/idp_eligibility/recommendation_grouper'
require 'models/idp_eligibility/filter'
require 'set'

module IdpEligibility
  describe RecommendationGrouper do
    let(:idp_one) { double(:idp_one, simple_id: 'idp') }
    let(:idp_two) { double(:idp_one, simple_id: 'idp2') }
    let(:singleton_idp) { [idp_one] }
    let(:recommended_rules) { { 'idp' => [[:passport]] } }
    let(:non_recommended_rules) { { 'idp' => [[:driving_licence]], 'idp2' => [[:passport]] } }
    let(:grouper) { RecommendationGrouper.new(recommended_rules, non_recommended_rules) }

    describe '#recommended?' do
      it 'should return false when idp cannot verify with evidence' do
        enabled_idps = singleton_idp
        user_docs = [:driving_licence]

        expect(grouper.recommended?(idp_one, user_docs, enabled_idps)).to eql(false)
      end

      it 'should return true when idp can verify with evidence' do
        enabled_idps = singleton_idp
        user_docs = [:passport]

        expect(grouper.recommended?(idp_one, user_docs, enabled_idps)).to eql(true)
      end
    end

    describe '#group_by_recommendation' do
      let(:multiple_idps) { [idp_one, idp_two] }

      it 'should return recommended idps' do
        user_docs = [:passport]
        grouped_idps = grouper.group_by_recommendation(user_docs, singleton_idp)
        expect(grouped_idps.recommended).to eql(singleton_idp)
        expect(grouped_idps.non_recommended).to eql([])
      end

      it 'should return non-recommended idps' do
        enabled_idps = multiple_idps
        user_docs = [:driving_licence]
        grouped_idps = grouper.group_by_recommendation(user_docs, enabled_idps)
        expect(grouped_idps.recommended).to eql([])
        expect(grouped_idps.non_recommended).to eql([idp_one])
      end

      it 'should return recommended and non-recommended idps' do
        enabled_idps = multiple_idps
        user_docs = [:passport, :driving_licence]
        grouped_idps = grouper.group_by_recommendation(user_docs, enabled_idps)
        expect(grouped_idps.recommended).to eql([idp_one])
        expect(grouped_idps.non_recommended).to eql([idp_two])
      end

      it 'should return an empty list when no enabled idps' do
        enabled_idps = []
        user_docs = [:passport]
        grouped_idps = grouper.group_by_recommendation(user_docs, enabled_idps)
        expect(grouped_idps.recommended).to eql([])
        expect(grouped_idps.non_recommended).to eql([])
      end
    end
  end
end
