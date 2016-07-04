module Display
  module Rp
    class Repository
      RpDisplayData = Struct.new(:other_ways_text, :other_ways_description, :name, :rp_name)
      RpFailedRegistrationDisplayData = Struct.new(:other_ways_text, :other_ways_description, :name, :rp_name)

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
        rp_name = @translator.translate("rps.#{simple_id}.rp_name")

        if CONTINUE_ON_FAILED_REGISTRATION_RPS.include?(simple_id)
          RpFailedRegistrationDisplayData.new(other_ways_text, other_ways_description, name, rp_name)
        else
          RpDisplayData.new(other_ways_text, other_ways_description, name, rp_name)
        end
      end
    end
  end
end
