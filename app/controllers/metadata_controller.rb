class MetadataController < ApplicationController
  skip_before_action :validate_cookies
  skip_after_action :store_locale_in_cookie

  METADATA_CONTENT_TYPE = 'application/samlmetadata+xml'.freeze

  def service_providers
    do_not_cache
    render xml: METADATA_CLIENT.idp_metadata, content_type: METADATA_CONTENT_TYPE
  end

  def identity_providers
    do_not_cache
    render xml: METADATA_CLIENT.sp_metadata, content_type: METADATA_CONTENT_TYPE
  end

private

  def do_not_cache
    response.headers['Cache-Control'] = 'no-cache, no-store, no-transform'
  end
end
