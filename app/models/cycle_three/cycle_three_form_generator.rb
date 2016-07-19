require 'cycle_three/cycle_three_form'

module CycleThree
  class CycleThreeFormGenerator
    class MissingDataError < StandardError
    end

    def initialize(file_loader)
      @file_loader = file_loader
    end

    def form_classes_by_name(directory_path)
      form_classes = {}
      begin
        @file_loader.load(directory_path).map do |attribute|
          pattern = attribute.fetch('pattern')
          length = attribute['length']
          nullable = attribute['nullable']
          form_classes[attribute.fetch('name')] = class_of(Regexp.new(pattern), length, nullable)
        end
      rescue KeyError => e
        raise MissingDataError, e.message
      end
      form_classes
    end

  private

    def class_of(regex, length, nullable)
      Class.new(CycleThreeForm) do
        define_method(:pattern) do
          regex
        end
        if length
          define_method(:sanitised_cycle_three_data) do
            super()[0, length]
          end
        end

        if nullable
          class << self
            define_method(:allows_nullable?) do
              true
            end
          end
        end
      end
    end
  end
end
