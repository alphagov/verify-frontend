class SegmentMatcher
  def initialize(segment_config)
    @segments = segment_config['segments']
    @segment_definitions = segment_config['segment_definitions']
  end

  def find_matching_segments(user_profile)
    user_profile_as_array_of_strings = user_profile.map(&:to_s)
    matching_segments = @segments
                           .select { |segment_name| segment_matches_profile(segment_name, user_profile_as_array_of_strings) }

    matching_segments.empty? ? %w(other) : matching_segments
  end

  def segment_matches_profile(segment_name, user_profile)
    @segment_definitions[segment_name].each do |segment_profile|
      if segment_profile.to_set == user_profile.to_set
        return true
      end
    end
    false
  end
end
