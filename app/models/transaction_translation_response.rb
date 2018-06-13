class TransactionTranslationResponse < Api::Response
  attr_reader :name, :rp_name, :analytics_description, :other_ways_text, :other_ways_description, :tailored_text, :taxon_name, :custom_fail_heading, :custom_fail_what_next_content, :custom_fail_other_options, :custom_fail_try_another_summary, :custom_fail_try_another_text, :custom_fail_contact_details_intro
  validates :name, :rp_name, :analytics_description, :other_ways_text, :other_ways_description, :tailored_text, :taxon_name, presence: true

  def initialize(hash)
    @name = hash['name']
    @rp_name = hash['rpName']
    @analytics_description = hash['analyticsDescription']
    @other_ways_text = hash['otherWaysText']
    @other_ways_description = hash['otherWaysDescription']
    @tailored_text = hash['tailoredText']
    @taxon_name = hash['taxonName']
    @custom_fail_heading = hash['customFailHeading']
    @custom_fail_what_next_content = hash['customFailWhatNextContent']
    @custom_fail_other_options = hash['customFailOtherOptions']
    @custom_fail_try_another_summary = hash['customFailTryAnotherSummary']
    @custom_fail_try_another_text = hash['customFailTryAnotherText']
    @custom_fail_contact_details_intro = hash['customFailContactDetailsIntro']
  end

  def to_h
    {
      name: name,
      rp_name: rp_name,
      analytics_description: analytics_description,
      other_ways_text: other_ways_text,
      other_ways_description: @other_ways_description,
      tailored_text: tailored_text,
      taxon_name: taxon_name,
      custom_fail_heading: custom_fail_heading,
      custom_fail_what_next_content: custom_fail_what_next_content,
      custom_fail_other_options: custom_fail_other_options,
      custom_fail_try_another_summary: custom_fail_try_another_summary,
      custom_fail_try_another_text: custom_fail_try_another_text,
      custom_fail_contact_details_intro: custom_fail_contact_details_intro
    }
  end
end
