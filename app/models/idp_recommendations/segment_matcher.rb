class SegmentMatcher
  def initialize(segment_config)
    @segment_groups = segment_config['segments']
    @segment_definitions = segment_config['segment_definitions']
  end

  def find_matching_segment(user_profile, transaction_group)
    user_profile_as_array_of_strings = user_profile.map(&:to_s)
    segments = @segment_groups[transaction_group]
    matching_segment = segments
                           .select { |segment_name| segment_matches_profile(segment_name, user_profile_as_array_of_strings) }
                           .first

    matching_segment.nil? ? 'other' : matching_segment
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
