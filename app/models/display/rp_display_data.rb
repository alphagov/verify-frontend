require 'display/display_data'
module Display
  class RpDisplayData < ::Display::DisplayData
    prefix :rps
    content :other_ways_description
    content :name
    content :rp_name
    content :other_ways_text
    content :analytics_description
    content :tailored_text
    content :custom_fail_heading, default: nil
    content :custom_fail_what_next_content, default: nil
    content :custom_fail_other_options, default: nil
    content :custom_fail_try_another_summary, default: nil
    content :custom_fail_try_another_text, default: nil
    content :custom_fail_contact_details_intro, default: nil
    content :taxon_name, default: -> { I18n.translate('hub.transaction_list.other_services') }
    alias_method :taxon, :taxon_name
  end
end
