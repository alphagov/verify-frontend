class StaticController < ApplicationController
  skip_before_action :validate_session
  skip_before_action :set_piwik_custom_variables

  def humanstxt
    render plain: 'GOV.UK Verify is built by a team at the Government Digital Service in London. If you\'d like to join us, see https://identityassurance.blog.gov.uk/work-with-us/'
  end
end
