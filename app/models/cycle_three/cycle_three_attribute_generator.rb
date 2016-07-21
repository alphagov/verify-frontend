require 'cycle_three/cycle_three_attribute'

module CycleThree
  class CycleThreeAttributeGenerator
    class MissingDataError < StandardError
    end

    def initialize(file_loader, cycle_display_data_repo)
      @file_loader = file_loader
      @cycle_display_data_repo = cycle_display_data_repo
    end

    def attribute_classes_by_name(directory_path)
      attribute_classes = {}
      begin
        @file_loader.load(directory_path).map do |attribute|
          pattern = attribute.fetch('pattern')
          length = attribute['length']
          nullable = attribute['nullable']
          simple_id = attribute.fetch('name')
          display_data = @cycle_display_data_repo.fetch(simple_id)
          attribute_classes[simple_id] = class_of(simple_id, Regexp.new(pattern), length, nullable, display_data)
        end
      rescue KeyError => e
        raise MissingDataError, e.message
      end
      attribute_classes
    end

  private

    def class_of(simple_id, regex, length, nullable, display_data)
      Class.new(CycleThreeAttribute) do
        define_singleton_method(:simple_id) do
          simple_id
        end

        define_method(:pattern) do
          regex
        end

        if length
          define_method(:sanitised_cycle_three_data) do
            super()[0, length]
          end
        end

        if nullable
          define_singleton_method(:allows_nullable?) do
            true
          end
        end

        define_singleton_method(:display_data) do
          display_data
        end
      end
    end
  end
end
