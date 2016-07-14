require 'yaml_loader'
require 'cycle_three/cycle_three_form'

module CycleThree
  class CycleThreeFormGenerator
    class MissingDataError < StandardError
    end

    def form_classes_by_name(directory_path)
      form_classes = {}
      begin
        load_yaml(directory_path).map do |attribute|
          pattern = attribute.fetch('pattern')
          length = attribute['length']
          form_classes[attribute.fetch('name')] = class_of(Regexp.new(pattern), length)
        end
      rescue KeyError => e
        raise MissingDataError, e.message
      end
      form_classes
    end

  private

    def class_of(regex, length)
      Class.new(CycleThreeForm) do
        define_method(:pattern) do
          regex
        end
        if length
          define_method(:sanitised_cycle_three_data) do
            super()[0, length]
          end
        end
      end
    end

    def load_yaml(path)
      YamlLoader.new.load(path)
    end
  end
end
