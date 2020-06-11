require "idp_recommendations/segment_matcher"

describe SegmentMatcher do
  let(:segments) {
    {
      "segments" => %w(segment1 segment2 segment3),
      "segment_definitions" => {
          "segment1" => [
              %w(passport driving_licence),
          ],
          "segment2" => [
              %w(passport driving_licence mobile_phone),
          ],
          "segment3" => [
              %w(passport driving_licence),
          ],
      },
    }
  }

  before(:each) do
    @segment_matcher = SegmentMatcher.new(segments)
  end

  describe "matching segment" do
    it "should find matching list of segments when profiles are an exact match across segments" do
      matching_profile = %i(passport driving_licence)
      matching_segment = @segment_matcher.find_matching_segments(matching_profile)
      expect(matching_segment).to eql %w(segment1 segment3)
    end

    it "should find one matching segment when profile appears only once across segments" do
      matching_profile = %i(driving_licence passport mobile_phone)
      matching_segment = @segment_matcher.find_matching_segments(matching_profile)
      expect(matching_segment).to eql %w(segment2)
    end
  end

  describe "no matching segment" do
    it "should return other if no match is found" do
      not_matching_profile = %i(driving_licence)
      matching_segment = @segment_matcher.find_matching_segments(not_matching_profile)
      expect(matching_segment).to eql %w(other)
    end

    it "should not find a match if the user profile is a superset of a segment profile" do
      not_matching_profile = %i(driving_licence passport mobile_phone smart_phone)
      matching_segment = @segment_matcher.find_matching_segments(not_matching_profile)
      expect(matching_segment).to eql %w(other)
    end
  end
end
