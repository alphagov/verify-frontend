require 'spec_helper'
require 'display_data_examples'
require 'display/display_data'
require 'display/idp_display_data'

module Display
  describe IdpDisplayData do
    [
      :name,
      :about,
      :requirements,
      :contact_details,
    ].each do |field|
      include_examples "has content", field, IdpDisplayData
    end

    [
      :tagline,
      :special_no_docs_instructions_html,
      :no_docs_requirement,
    ].each do |field|
      include_examples "has content with default", field, IdpDisplayData
    end
  end
end
