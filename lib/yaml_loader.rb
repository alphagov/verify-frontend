require 'yaml'

class YamlLoader
  def load(path)
    files = File.join(path, '*.yml')
    Dir::glob(files).map do |file|
      YAML::load_file(file)
    end
  end
end
