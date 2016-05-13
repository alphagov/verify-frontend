module Display
  module Rp
    class Repository
      RpDisplayData = Struct.new(:other_ways_text, :other_ways_description, :name)

      def initialize(translator)
        @translator = translator
      end

      def fetch(simple_id)
        if simple_id.nil?
          raise StandardError, 'No transaction simple id in session'
        end
        other_ways_text = @translator.translate("rps.#{simple_id}.other_ways_text")
        other_ways_description = @translator.translate("rps.#{simple_id}.other_ways_description")
        name = @translator.translate("rps.#{simple_id}.name")
        RpDisplayData.new(other_ways_text, other_ways_description, name)
      end
    end
  end
end
