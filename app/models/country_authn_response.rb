class CountryAuthnResponse < Api::Response
  attr_reader :country_result, :is_registration, :loa_achieved
  validates_presence_of :country_result
  validates_inclusion_of :loa_achieved, in: ['LEVEL_1', 'LEVEL_2', nil]
  validates_inclusion_of :is_registration, in: [true, false]

  def initialize(hash)
    @country_result = hash['countryResult']
    @is_registration = hash['isRegistration']
    @loa_achieved = hash['loaAchieved']
  end
end
