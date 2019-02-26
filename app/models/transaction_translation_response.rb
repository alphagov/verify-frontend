class TransactionTranslationResponse < Api::Response
  attr_reader :name, :rp_name, :analytics_description, :other_ways_text, :other_ways_description, :tailored_text,
              :taxon_name, :custom_fail_heading, :custom_fail_what_next_content, :custom_fail_other_options,
              :custom_fail_try_another_summary, :custom_fail_try_another_text, :custom_fail_contact_details_intro,
              :single_idp_start_page_content_html, :single_idp_start_page_title, :idp_disconnected_alternative_html
  validates :name, :rp_name, :analytics_description, :other_ways_text, :other_ways_description, :tailored_text, presence: true

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
    @single_idp_start_page_content_html = hash['singleIdpStartPageContent']
    @single_idp_start_page_title = hash['singleIdpStartPageTitle']
    @idp_disconnected_alternative_html = hash['idpDisconnectedAlternativeHtml']
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
      custom_fail_contact_details_intro: custom_fail_contact_details_intro,
      single_idp_start_page_content_html: @single_idp_start_page_content_html,
      single_idp_start_page_title: @single_idp_start_page_title,
      idp_disconnected_alternative_html: @idp_disconnected_alternative_html
    }
  end
end
