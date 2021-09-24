require "idp_recommendations/segment_matcher"
require "idp_recommendations/transaction_grouper"

class RecommendationsEngine
  def initialize(idp_rules, segment_matcher, transaction_grouper, hide_soft_disconnecting_idps_mins)
    @idp_rules = idp_rules
    @segment_matcher = segment_matcher
    @transaction_grouper = transaction_grouper
    @hide_soft_disconnecting_idps_mins = hide_soft_disconnecting_idps_mins
  end

  def get_suggested_idps_for_registration(idps, user_profile, transaction_simple_id)
    viewable_idps = idps.reject { |idp| is_hidden_for_registration?(idp) }
    transaction_group = @transaction_grouper.get_transaction_group(transaction_simple_id)
    user_segments = @segment_matcher.find_matching_segments(user_profile)

    recommended_idps = viewable_idps.select { |idp| is_recommended_for_segment(idp, user_segments, transaction_group) }
    unlikely_idps = viewable_idps.select { |idp| is_unlikely_for_segment(idp, user_segments, transaction_group) }

    { recommended: recommended_idps, unlikely: unlikely_idps, user_segments: user_segments }
  end

  def recommended?(idp, enabled_idps, user_profile, transaction_simple_id)
    suggested_idps = get_suggested_idps_for_registration(enabled_idps, user_profile, transaction_simple_id)
    suggested_idps[:recommended].include? idp
  end

  def any?(idps, user_profile, transaction_simple_id)
    suggested_idps = get_suggested_idps_for_registration(idps, user_profile, transaction_simple_id)
    suggested_idps[:recommended].any? || suggested_idps[:unlikely].any?
  end

private

  def is_hidden_for_registration?(idp)
    return false if idp.provide_registration_until.nil?

    idp.provide_registration_until - @hide_soft_disconnecting_idps_mins.minutes < DateTime.now
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
