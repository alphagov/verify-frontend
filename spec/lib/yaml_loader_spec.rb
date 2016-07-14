require 'tmpdir'
require 'yaml_loader'

describe YamlLoader do
  it 'loads yaml from a directory' do
    Dir.mktmpdir('yamlloaderspecfiles') { |dir|
      File.open(File.join(dir, 'yaml1.yml'), 'w') { |file|
        file.puts("name: Lloyd\nfavourite_colour: ruby")
      }
      File.open(File.join(dir, 'yaml2.yml'), 'w') { |file|
        file.puts("name: Tom\nfavourite_colour: java")
      }
      yaml_loader = YamlLoader.new

      expected = [
        { "name" => "Lloyd", "favourite_colour" => "ruby" },
        { "name" => "Tom", "favourite_colour" => "java" }
      ]
      expect(yaml_loader.load(dir)).to eql(expected)
    }
  end
end
