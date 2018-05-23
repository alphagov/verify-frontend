class TransactionTranslationResponse < Api::Response
  attr_reader :name, :rp_name, :analytics_description, :other_ways_text, :other_ways_description, :tailored_text, :taxon_name
  validates :name, :rp_name, :analytics_description, :other_ways_text, :other_ways_description, :tailored_text, :taxon_name, presence: true

  def initialize(hash)
    @name = hash['name']
    @rp_name = hash['rpName']
    @analytics_description = hash['analyticsDescription']
    @other_ways_text = hash['otherWaysText']
    @other_ways_description = hash['otherWaysDescription']
    @tailored_text = hash['tailoredText']
    @taxon_name = hash['taxonName']
  end
end