require 'api/response'
class TransactionResponse < Api::Response
  attr_reader :simple_id, :transaction_homepage, :levels_of_assurance
  validates :simple_id, :transaction_homepage, :levels_of_assurance, presence: true

  def initialize(hash)
    @simple_id = hash['simpleId']
    @transaction_homepage = hash['serviceHomepage']
    @levels_of_assurance = hash['loaList']
  end

  alias_method :homepage, :transaction_homepage
  alias_method :loa_list, :levels_of_assurance
end
