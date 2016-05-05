class FederationInfoResponse < Api::Response
  attr_reader :idps
  validate :consistent_idps

  def initialize(hash)
    @idps = hash['idps'].map { |idp| IdentityProvider.from_api(idp) }
  end

  def consistent_idps
    return if @idps.empty?
    if @idps.none?(&:valid?)
      errors.add(:identity_providers, 'are malformed')
    end
  end
end
