module Display
  class DisplayData
    attr_reader :simple_id
    def initialize(simple_id, translator)
      @simple_id = simple_id
      @translator = translator
    end

    class << self
      attr_reader :localizable_fields

      def content(field, options = {})
        define_method(field) do
          begin
            @translator.translate("#{prefix}.#{simple_id}.#{field}")
          rescue StandardError => e
            options.fetch(:default) { raise e }
          end
        end
        @localizable_fields ||= []
        @localizable_fields << field
      end

      def prefix(value)
        define_method :prefix do
          value
        end
      end
    end

    def validate_content!
      self.class.localizable_fields.each do |field|
        self.public_send(field)
      end
    end

    def prefix
      raise NotImplementedError, 'no prefix has been defined'
    end
  end
end
