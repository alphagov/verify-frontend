require 'idp_recommendations/segment_matcher'
require 'idp_recommendations/transaction_grouper'

class RecommendationsEngine
  def initialize(idp_rules, segment_matcher, transaction_grouper)
    @idp_rules = idp_rules
    @segment_matcher = segment_matcher
    @transaction_grouper = transaction_grouper
  end

  def get_suggested_idps(idps, user_profile, transaction_simple_id)
    capable_idps = idps.select { |idp| is_capable?(idp, user_profile) }
    transaction_group = @transaction_grouper.get_transaction_group(transaction_simple_id)
    user_segments = @segment_matcher.find_matching_segments(user_profile)

    recommended_idps = capable_idps.select { |idp| is_recommended_for_segment(idp, user_segments, transaction_group) }
    unlikely_idps = capable_idps.select { |idp| is_unlikely_for_segment(idp, user_segments, transaction_group) }

    { recommended: recommended_idps, unlikely: unlikely_idps, user_segments: user_segments }
  end

  def recommended?(idp, enabled_idps, user_profile, transaction_simple_id)
    suggested_idps = get_suggested_idps(enabled_idps, user_profile, transaction_simple_id)
    suggested_idps[:recommended].include? idp
  end

  def any?(idps, user_profile, transaction_simple_id)
    suggested_idps = get_suggested_idps(idps, user_profile, transaction_simple_id)
    suggested_idps[:recommended].any? || suggested_idps[:unlikely].any?
  end

private

  def is_capable?(idp, user_profile)
    @idp_rules[idp.simple_id].capabilities.each do |characteristic_set|
      if user_profile_contains_all_capabilities(user_profile, characteristic_set)
        return true
      end
    end
    false
  end

  def user_profile_contains_all_capabilities(user_profile, capabilities)
    capabilities.all? { |characteristic| user_profile.include? characteristic.to_sym }
  end

  def is_recommended_for_segment(idp, user_segments, transaction_group)
    segments_for_idp = @idp_rules[idp.simple_id].recommended_segments(transaction_group)
    !(segments_for_idp & user_segments).empty?
  end

  def is_unlikely_for_segment(idp, user_segments, transaction_group)
    segments_for_idp = @idp_rules[idp.simple_id].unlikely_segments(transaction_group)
    !(segments_for_idp & user_segments).empty?
  end
end
