require 'tmpdir'
require 'yaml_loader'

describe YamlLoader do
  let(:yaml_loader) {
    YamlLoader.new
  }
  it 'loads yaml from a directory' do
    Dir.mktmpdir('yamlloaderspecfiles') { |dir|
      File.open(File.join(dir, 'yaml1.yml'), 'w') { |file|
        file.puts("name: Lloyd\nfavourite_colour: ruby")
      }
      File.open(File.join(dir, 'yaml2.yml'), 'w') { |file|
        file.puts("name: Tom\nfavourite_colour: java")
      }

      expected = [
        { "name" => "Lloyd", "favourite_colour" => "ruby" },
        { "name" => "Tom", "favourite_colour" => "java" }
      ]
      expect(yaml_loader.load(dir)).to match_array(expected)
    }
  end

  it 'loads an empty list from empty directory' do
    Dir.mktmpdir('yamlloaderspecfiles') { |dir|
      expect(yaml_loader.load(dir)).to eql([])
    }
  end

  it 'raises error when yaml is invalid' do
    Dir.mktmpdir('yamlloaderspecfiles') { |dir|
      File.open(File.join(dir, 'yaml1.yml'), 'w') { |file|
        file.puts("name: Lloyd\n favourite_colour: ruby")
      }

      expect {
        yaml_loader.load(dir)
      }.to raise_error(Psych::SyntaxError)
    }
  end
end
