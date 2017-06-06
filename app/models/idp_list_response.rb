class IdpListResponse < Api::Response
  attr_reader :idps
  validate :consistent_idps

  def initialize(hash)
    @idps = hash.map { |idp| IdentityProvider.new(idp) }
  end

  def consistent_idps
    return if @idps.empty?
    if @idps.none?(&:valid?)
      errors.add(:identity_providers, 'are malformed')
    end
  end
end
