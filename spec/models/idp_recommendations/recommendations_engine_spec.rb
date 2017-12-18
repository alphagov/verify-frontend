require 'idp_recommendations/recommendations_engine'
require 'idp_recommendations/idp_rules'
require 'idp_recommendations/transaction_grouper'

describe 'recommendations engine' do
  let(:idp_one) { double(:idp_one, simple_id: 'idp') }
  let(:idp_two) { double(:idp_two, simple_id: 'idp2') }
  let(:idp_three) { double(:idp_three, simple_id: 'idp3') }
  let(:less_capable_idp) { double(:less_capable_idp, simple_id: 'less_capable_idp') }
  let(:idps) { [idp_one, idp_two, idp_three, less_capable_idp] }
  let(:user_profile) { %i(driving_licence passport) }
  let(:idp_rules) {
    {
        'idp' => generate_idp_rules(capabilities: ['passport'], protected_recommended_segments: %w(SEGMENT_1)),
        'idp2' => generate_idp_rules(capabilities: ['passport'], protected_unlikely_segments: %w(SEGMENT_1 SEGMENT_2)),
        'idp3' => generate_idp_rules(capabilities: ['passport']),
        'less_capable_idp' => generate_idp_rules(capabilities: %w(passport smart_phone), protected_recommended_segments: %w(SEGMENT_1)),
    }
  }
  let(:segment_matcher) { double('segment_matcher') }
  let(:transaction_grouper) { double('transaction_grouper') }

  before(:each) do
    @recommendations_engine = RecommendationsEngine.new(idp_rules, segment_matcher, transaction_grouper)
  end

  it 'should return recommendations given a user profile' do
    allow(segment_matcher).to receive(:find_matching_segments).with(user_profile).and_return(%w(SEGMENT_1))
    allow(transaction_grouper).to receive(:get_transaction_group).with('test-rp').and_return(TransactionGroups::PROTECTED)

    recommended_idps = @recommendations_engine.get_suggested_idps(idps, user_profile, 'test-rp')

    expected_suggestions = { recommended: [idp_one], unlikely: [idp_two], user_segments: %w(SEGMENT_1) }
    expect(recommended_idps).to eql expected_suggestions
  end

  describe 'recommended?' do
    before(:each) do
      allow(segment_matcher).to receive(:find_matching_segments).with(user_profile).and_return(%w(SEGMENT_1))
      allow(transaction_grouper).to receive(:get_transaction_group).with('test-rp').and_return(TransactionGroups::PROTECTED)
    end

    it 'should return true if the idp is in the recommended list' do
      result = @recommendations_engine.recommended?(idp_one, idps, user_profile, 'test-rp')
      expect(result).to eql true
    end

    it 'should return false if the idp is in the unlikely list' do
      result = @recommendations_engine.recommended?(idp_two, idps, user_profile, 'test-rp')
      expect(result).to eql false
    end

    it 'should return false if the idp is not recommended' do
      result = @recommendations_engine.recommended?(idp_three, idps, user_profile, 'test-rp')
      expect(result).to eql false
    end
  end

  describe 'any?' do
    before(:each) do
      allow(segment_matcher).to receive(:find_matching_segments).with(user_profile).and_return(%w(SEGMENT_1))
      allow(transaction_grouper).to receive(:get_transaction_group).with('test-rp').and_return(TransactionGroups::PROTECTED)
    end

    it 'should return true if there is at least 1 recommended IDP' do
      result = @recommendations_engine.any?([idp_one], user_profile, 'test-rp')
      expect(result).to eql true
    end

    it 'should return true if there is at least 1 unlikely IDP' do
      result = @recommendations_engine.any?([idp_two], user_profile, 'test-rp')
      expect(result).to eql true
    end

    it 'should return false if there are no recommended or unlikely IDPs' do
      result = @recommendations_engine.any?([idp_three], user_profile, 'test-rp')
      expect(result).to eql false
    end
  end

  def generate_idp_rules(capabilities: [],
                         protected_recommended_segments: [],
                         protected_unlikely_segments: [],
                         non_protected_recommended_segments: [],
                         non_protected_unlikely_segments: [])
    IdpRules.new(
      'capabilities' => [capabilities],
      'segments' => {
        'protected' => {
          'recommended' => protected_recommended_segments,
          'unlikely' => protected_unlikely_segments
        },
        'non_protected' => {
          'recommended' => non_protected_recommended_segments,
          'unlikely' => non_protected_unlikely_segments
        }
      }
    )
  end
end
