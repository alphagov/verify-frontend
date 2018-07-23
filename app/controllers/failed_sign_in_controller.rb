class FailedSignInController < ApplicationController
  def idp
    @entity = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(selected_identity_provider)
  end

  def country
    @entity = COUNTRY_DISPLAY_DECORATOR.decorate(selected_country)
    @other_ways_description = current_transaction.other_ways_description
    @other_ways_text = current_transaction.other_ways_text
  end
end
