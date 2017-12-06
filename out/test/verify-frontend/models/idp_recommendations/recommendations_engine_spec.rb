require 'idp_recommendations/recommendations_engine'
require 'idp_recommendations/idp_segments'
require 'idp_recommendations/transaction_grouper'

describe 'recommendations engine' do
  let(:idp_one) { double(:idp_one, simple_id: 'idp') }
  let(:idp_two) { double(:idp_two, simple_id: 'idp2') }
  let(:idp_three) { double(:idp_three, simple_id: 'idp3') }
  let(:idps) { [idp_one, idp_two, idp_three] }
  let(:user_profile) { %i(driving_licence passport) }
  let(:idp_rules) {
    {
        'idp' => IdpSegments.new('for_protected' => { 'likely' => ['SEGMENT_1'], 'unlikely' => [] }, 'for_non_protected' => { 'likely' => [], 'unlikely' => [] }),
        'idp2' => IdpSegments.new('for_protected' => { 'likely' => [], 'unlikely' => ['SEGMENT_1'] }, 'for_non_protected' => { 'likely' => [], 'unlikely' => [] }),
        'idp3' => IdpSegments.new('for_protected' => { 'likely' => [], 'unlikely' => [] }, 'for_non_protected' => { 'likely' => [], 'unlikely' => [] }),
    }
  }
  let(:segment_matcher) { double('segment_matcher') }
  let(:transaction_grouper) { double('transaction_grouper') }

  before(:each) do
    @recommendations_engine = RecommendationsEngine.new(idp_rules, segment_matcher, transaction_grouper)
  end

  it 'should return recommendations given a user profile' do
    allow(segment_matcher).to receive(:find_matching_segment).with(user_profile).and_return('SEGMENT_1')
    allow(transaction_grouper).to receive(:get_transaction_group).with('test-rp').and_return(TransactionGroups::PROTECTED)

    recommended_idps = @recommendations_engine.recommendations(idps, user_profile, 'test-rp')

    expected_idps = { recommended: [idp_one], unlikely: [idp_two] }
    expect(recommended_idps).to eql expected_idps
  end

  describe 'recommended?' do
    before(:each) do

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
end
