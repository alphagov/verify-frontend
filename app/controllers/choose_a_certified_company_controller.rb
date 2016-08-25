class ChooseACertifiedCompanyController < ApplicationController
  def index
    @recommended_idps = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(grouped_identity_providers.recommended)
    @non_recommended_idps = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(grouped_identity_providers.non_recommended)
  end

  def select_idp
    select_viewable_idp(params.fetch('entity_id')) do |decorated_idp|
      recommended = IDP_RECOMMENDATION_GROUPER.recommended?(decorated_idp.identity_provider, selected_evidence, current_identity_providers, current_transaction_simple_id)
      session[:selected_idp_was_recommended] = recommended

      store_selected_idp_index
      store_num_of_idps(recommended)

      redirect_to redirect_to_idp_warning_path
    end
  end

  def about
    simple_id = params[:company]
    matching_idp = current_identity_providers.detect { |idp| idp.simple_id == simple_id }
    @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(matching_idp)
    if @idp.viewable?
      @recommended = IDP_RECOMMENDATION_GROUPER.recommended?(@idp, selected_evidence, current_identity_providers, current_transaction_simple_id)
      render 'about'
    else
      render 'errors/404', status: 404
    end
  end

private

  def grouped_identity_providers
    @grouped_identity_providers ||= IDP_RECOMMENDATION_GROUPER.group_by_recommendation(selected_evidence, current_identity_providers, current_transaction_simple_id)
  end

  def store_selected_idp_index
    raw_index = params['selected_idp_index']
    begin
      flash[:selected_idp_index] = Integer(raw_index)
    rescue TypeError, ArgumentError
      Rails.logger.warn('Could not parse selected_idp_index as an Integer.')
    end
  end

  def store_num_of_idps(recommended)
    # This is the count of idps in the group the user clicked (recommended or non-recommended)
    # It's used to report to piwik that the user clicked e.g. "index 2 of 4"
    flash[:idp_count] = recommended ? grouped_identity_providers.recommended.count : grouped_identity_providers.non_recommended.count
  end
end
