class MetadataController < ApplicationController
  skip_before_action :validate_cookies

  def service_providers
    render xml: METADATA_CLIENT.sp_metadata
  end

  def identity_providers
    render xml: METADATA_CLIENT.idp_metadata
  end
end
