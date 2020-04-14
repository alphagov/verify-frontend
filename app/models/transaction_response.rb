class TransactionResponse < Api::Response
  attr_reader :simple_id, :transaction_homepage, :levels_of_assurance, :headless_startpage
  validates :simple_id, :transaction_homepage, :levels_of_assurance, presence: true

  def initialize(hash)
    @simple_id = hash["simpleId"]
    @transaction_homepage = hash["serviceHomepage"]
    @levels_of_assurance = hash["loaList"]
    @headless_startpage = hash["headlessStartpage"]
  end
end
