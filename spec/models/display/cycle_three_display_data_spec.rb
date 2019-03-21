require 'spec_helper'
require 'display_data_examples'
require 'display/display_data'

module Display
  describe CycleThreeDisplayData do
    %i[
      intro_html
      name
      field_name
      help_to_find
      example
    ].each do |field|
      include_examples "has content", field, CycleThreeDisplayData
    end
  end
end
