require "yaml"

class YamlLoader
  def load(path)
    load_with_id(path).values
  end

  def load_with_id(path)
    files = File.join(path, "*.yml")
    loaded_files = Dir.glob(files).map do |file|
      [File.basename(file, ".yml"), YAML.load_file(file)]
    end
    loaded_files.to_h
  end
end
