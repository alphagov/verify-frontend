require 'fileutils'
namespace :zdd do
  desc 'set the service unavailable'
  task set_unavailable: :environment do
    FileUtils.touch(CONFIG.zdd_file)
  end

  desc 'reset service availability'
  task reset: :environment do
    FileUtils.rm(CONFIG.zdd_file, force: true)
    sleep Integer(CONFIG.polling_wait_time)
  end
end
