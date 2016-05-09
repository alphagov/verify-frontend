class IdpAuthnResponse < Api::Response
  attr_reader :idp_result, :is_registration
  validates_presence_of :idp_result
  validates_inclusion_of :is_registration, in: [true, false]

  def initialize(hash)
    @idp_result = hash['idpResult']
    @is_registration = hash['isRegistration']
  end
end
