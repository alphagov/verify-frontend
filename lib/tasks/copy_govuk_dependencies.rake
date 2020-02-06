require 'fileutils'

desc 'Copy and undigest govuk-frontend assets'

namespace :assets do
  def copy_govuk_dependencies
    puts "INFO - Copying govuk-frontend assets"
    source = 'lib/node_modules/govuk-frontend/govuk/assets/'
    destination = 'public/assets/govuk-frontend/govuk/assets/'
    dirname = File.dirname(destination)
    FileUtils.mkdir_p(dirname)
    FileUtils.copy_entry source, destination
  end

  def undigest_font_and_image_assets
    puts 'INFO - undigesting govuk-frontend image and font assets'
    build_number_file = File.expand_path('../../.build-number', __dir__)
    build = if File.exist?(build_number_file)
              "#{File.read(build_number_file).chomp}/"
            else
              ''
            end
    path = File.join(Rails.root, "./public/#{build}govuk-frontend/govuk/assets/**/*")
    assets = Dir.glob(path)
    puts "INFO - Found #{assets.length} assets to examine from #{path}"
    regex = /(-{1}[a-z0-9]{32}*\.{1}){1}/
    fonts_and_images = ['.png', '.svg', '.woff', '.woff2']
    assets.each do |file|
      next if File.directory?(file) || (fonts_and_images.include?(File.extname(file)) && file !~ regex)

      puts "INFO - Undigesting asset #{file}"
      source = file.split('/')
      source.push(source.pop.gsub(regex, '.'))
      non_digested = File.join(source)
      FileUtils.copy_file(file, non_digested)
      puts "INFO - Undigested asset at #{non_digested}"
    end
  end

  task :precompile do
    copy_govuk_dependencies
    undigest_font_and_image_assets
  end
end
