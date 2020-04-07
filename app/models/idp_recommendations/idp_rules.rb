require "idp_recommendations/transaction_grouper"

class IdpRules
  attr_reader :capabilities

  def initialize(idp_rules)
    segments = idp_rules["segments"]
    @protected_recommended_segments = segments["protected"]["recommended"]
    @protected_unlikely_segments = segments["protected"]["unlikely"]
    @non_protected_recommended_segments = segments["non_protected"]["recommended"]
    @non_protected_unlikely_segments = segments["non_protected"]["unlikely"]
    @capabilities = idp_rules["capabilities"]
  end

  def recommended_segments(transaction_group)
    transaction_group == TransactionGroups::PROTECTED ? @protected_recommended_segments : @non_protected_recommended_segments
  end

  def unlikely_segments(transaction_group)
    transaction_group == TransactionGroups::PROTECTED ? @protected_unlikely_segments : @non_protected_unlikely_segments
  end
end
