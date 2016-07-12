require 'fileutils'
namespace :zdd do
  def zdd_file
    ENV.fetch('ZDD_LATCH') {
      raise "ZDD_LATCH environment variable is unset!"
    }
  end

  def wait_time
    ENV.fetch('POLLING_WAIT_TIME') {
      raise "POLLING_WAIT_TIME environment variable is unset!"
    }
  end

  desc 'set the service unavailable'
  task :set_unavailable do
    FileUtils.touch(zdd_file)
    sleep Integer(wait_time)
  end

  desc 'reset service availability'
  task :reset do
    FileUtils.rm(zdd_file, force: true)
  end
end
