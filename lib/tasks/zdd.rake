require "fileutils"
namespace :zdd do
  desc "set the service unavailable"
  task :set_unavailable do
    FileUtils.touch(RakeZdd.zdd_file)
    sleep Integer(RakeZdd.wait_time)
  end

  desc "reset service availability"
  task :reset do
    FileUtils.rm(RakeZdd.zdd_file, force: true)
  end
end

class RakeZdd
  class << RakeZdd
    def zdd_file
      ENV.fetch("ZDD_LATCH") {
        raise "ZDD_LATCH environment variable is unset!"
      }
    end

    def wait_time
      ENV.fetch("POLLING_WAIT_TIME") {
        raise "POLLING_WAIT_TIME environment variable is unset!"
      }
    end
  end
end
