require 'idp_recommendations/segment_matcher'

describe SegmentMatcher do
  let(:segments) {
    {
      'segments' => {
        'protected' => [
          'segment1'
        ],
        'non-protected' => [
          'segment2'
        ]
      },
      'segment_definitions' => {
          'segment1' => [
              %w(passport driving_licence)
          ],
          'segment2' => [
              %w(passport driving_licence)
          ]
      }
    }
  }


  before(:each) do
    @segment_matcher = SegmentMatcher.new(segments)
  end

  describe 'matching segment' do
    it 'should find match when segments are an exact match in protected segment for protected transaction' do
      matching_profile = %i(passport driving_licence)
      matching_segment = @segment_matcher.find_matching_segment(matching_profile, 'protected')
      expect(matching_segment).to eql 'segment1'
    end

    it 'should find match when segments are an exact match apart from order in non-protected segment for non-protected transaction' do
      matching_profile = %i(driving_licence passport)
      matching_segment = @segment_matcher.find_matching_segment(matching_profile, 'non-protected')
      expect(matching_segment).to eql 'segment2'
    end
  end

  describe 'no matching segment' do
    it 'should return other if no match is found' do
      not_matching_profile = %i(driving_licence)
      matching_segment = @segment_matcher.find_matching_segment(not_matching_profile, 'protected')
      expect(matching_segment).to eql 'other'
    end

    it 'should not find a match if the user profile is a superset of a segment profile' do
      not_matching_profile = %i(driving_licence passport mobile_phone)
      matching_segment = @segment_matcher.find_matching_segment(not_matching_profile, 'protected')
      expect(matching_segment).to eql 'other'
    end
  end
end
