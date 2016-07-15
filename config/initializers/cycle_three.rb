require 'yaml_loader'

CYCLE_THREE_FORMS = CycleThree::CycleThreeFormGenerator.new(YamlLoader.new).form_classes_by_name(CONFIG.cycle_three_attributes_directory)
