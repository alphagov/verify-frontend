class IdpAuthnResponse < Api::Response
  attr_reader :idp_result, :is_registration, :loa_achieved, :assertion_expiry
  validates_presence_of :idp_result
  validates_inclusion_of :loa_achieved, in: [LevelOfAssurance::LOA1, LevelOfAssurance::LOA2, nil]
  validates_inclusion_of :is_registration, in: [true, false]

  def initialize(hash)
    hash.symbolize_keys!
    @idp_result = hash[:result]
    @is_registration = hash[:isRegistration]
    @loa_achieved = hash[:loaAchieved]
    @assertion_expiry = hash[:notOnOrAfter]
  end
end
