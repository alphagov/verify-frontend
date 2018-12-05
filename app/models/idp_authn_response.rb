class IdpAuthnResponse < Api::Response
  attr_reader :idp_result, :is_registration, :loa_achieved, :not_on_or_after
  validates_presence_of :idp_result
  validates_inclusion_of :loa_achieved, in: ['LEVEL_1', 'LEVEL_2', nil]
  validates_inclusion_of :is_registration, in: [true, false]

  def initialize(hash)
    @idp_result = hash['result']
    @is_registration = hash['isRegistration']
    @loa_achieved = hash['loaAchieved']
    @not_on_or_after = hash['notOnOrAfter']
  end
end
