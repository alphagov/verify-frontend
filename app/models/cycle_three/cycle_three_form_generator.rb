require 'yaml'
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
          form_classes[attribute.fetch('name')] = class_of(Regexp.new(pattern))
        end
      rescue KeyError => e
        raise MissingDataError, e.message
      end
      form_classes
    end

  private

    def class_of(regex)
      Class.new(CycleThreeForm) do
        define_method(:pattern) do
          regex
        end
      end
    end

    def load_yaml(path)
      files = File.join(path, '*.yml')
      Dir::glob(files).map do |file|
        YAML::load_file(file)
      end
    end
  end
end
