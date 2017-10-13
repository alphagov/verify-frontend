require 'spec_helper'
require 'display_data_examples'
require 'display/display_data'
require 'display/rp_display_data'

module Display
  describe RpDisplayData do
    %i[
      other_ways_description
      name
      rp_name
      other_ways_text
      tailored_text
    ].each do |field|
      include_examples "has content", field, RpDisplayData
    end
  end
end
