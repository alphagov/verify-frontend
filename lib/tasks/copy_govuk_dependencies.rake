require 'fileutils'

desc 'Copy govuk-frontend assets'
task 'copy_govuk_dependencies' do
  source = 'lib/node_modules/govuk-frontend/govuk/assets/'
  destination = 'public/assets/govuk-frontend/govuk/assets/'

  dirname = File.dirname(destination)
  FileUtils.mkdir_p(dirname)
  FileUtils.copy_entry source, destination
end
