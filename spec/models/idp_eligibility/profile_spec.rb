require 'idp_eligibility/profile'

module IdpEligibility
  describe Profile do
    describe '#&' do
      it 'should mask the profile given an array of attributes' do
        masked_profile = Profile.new(%i[passport mobile_phone]) & [:passport]
        expect(masked_profile).to eq(Profile.new([:passport]))
      end
      it 'should return an empty profile if mask only contains attributes not in the profile' do
        masked_profile = Profile.new(%i[passport mobile_phone]) & [:driving_licence]
        expect(masked_profile).to eq(Profile.new([]))
      end
    end
    describe '#applies_to' do
      it 'should return true if the evidence is a permutation match of the profile' do
        profile = Profile.new(%i[passport mobile_phone])
        expect(profile.applies_to?(%i[mobile_phone passport])).to eq true
      end

      it 'should return false if the evidence contains more information than the profile' do
        profile = Profile.new(%i[passport mobile_phone])
        expect(profile.applies_to?(%i[passport mobile_phone driving_licence])).to eq false
      end

      it 'should return false if the profile is not a subset of the supplied evidence' do
        profile = Profile.new(%i[passport mobile_phone])
        expect(profile.applies_to?(%i[passport driving_licence])).to eq false
      end

      it 'should return false if the profile is empty' do
        profile = Profile.new([])
        expect(profile.applies_to?([:passport])).to eq false
      end
    end

    describe '#==' do
      it 'is eq when the rule array matches' do
        expect(Profile.new([:passport])).to eq Profile.new([:passport])
      end

      it 'is not eq when the rule array doesn\'t match' do
        expect(Profile.new([:passport])).to_not eq Profile.new([:driving_licence])
      end
    end
  end
end
