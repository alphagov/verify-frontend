class ServiceStatusController < ApplicationController
  skip_before_action :validate_cookies

  def zdd_latch_file
    ENV.fetch('ZDD_LATCH')
  end

  def index
    if File.exist?(zdd_latch_file)
      render nothing: true, status: 503
    else
      render nothing: true, status: 200
    end
  end
end
