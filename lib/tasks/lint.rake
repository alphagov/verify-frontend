namespace :lint do
  desc 'lint ruby files'
  task :ruby do
    sh 'govuk-lint-ruby app config lib spec', verbose: false do |ok, _|
      if ok
        green('Ruby linting PASSED')
      else
        red('Ruby linting FAILED')
        exit(1)
      end
    end
  end

  desc 'lint sass files'
  task :sass do
    scss_files = FileList.new do |fl|
      fl.include('app/assets/stylesheets/*.scss')
      fl.include('app/assets/stylesheets/*/*.scss')
      fl.exclude('app/assets/stylesheets/vendor/*.scss')
    end
    sh 'govuk-lint-sass', *scss_files, verbose: false do |ok, _|
      if ok
        green('SASS linting PASSED')
      else
        red('SASS linting FAILED')
        exit(1)
      end
    end
  end

private

  def green(msg)
    puts ENV['TERM'] ? "#{`tput setaf 2`}#{msg}#{`tput sgr0`}" : msg
  end

  def red(msg)
    puts ENV['TERM'] ? "#{`tput setaf 1`}#{msg}#{`tput sgr0`}" : msg
  end
end
