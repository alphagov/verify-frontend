class ChooseACertifiedCompanyController < ApplicationController
  include AbTestHelper

  def index
    rankings = IDP_RANKER.rank(selected_evidence)
    if rankings.has_rank?
      report_idp_ranking_ab_test
    end

    grouped_identity_providers = select_idp_recommendation.group_by_recommendation(selected_evidence, current_identity_providers, current_transaction_simple_id)
    @recommended_idps = fetch_recommended_idps(grouped_identity_providers, rankings)
    @non_recommended_idps = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(grouped_identity_providers.non_recommended)
  end



  def select_idp
    select_viewable_idp(params.fetch('entity_id')) do |decorated_idp|
      session[:selected_idp_was_recommended] = select_idp_recommendation.recommended?(decorated_idp.identity_provider, selected_evidence, current_identity_providers, current_transaction_simple_id)
      redirect_to redirect_to_idp_warning_path
    end
  end

  def about
    simple_id = params[:company]
    matching_idp = current_identity_providers.detect { |idp| idp.simple_id == simple_id }
    @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(matching_idp)
    if @idp.viewable?
      @recommended = select_idp_recommendation.recommended?(@idp, selected_evidence, current_identity_providers, current_transaction_simple_id)
      render 'about'
    else
      render 'errors/404', status: 404
    end
  end

private

  def fetch_recommended_idps(grouped_identity_providers, rankings)
    if is_in_idp_ranking_by_completion_group?
      IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection_with_ranking(grouped_identity_providers.recommended, rankings)
    else
      IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(grouped_identity_providers.recommended)
    end
  end

  def select_idp_recommendation
    if is_in_b_group?
      return IDP_RECOMMENDATION_GROUPER_B
    else
      return IDP_RECOMMENDATION_GROUPER
    end
  end

  def report_idp_ranking_ab_test
    AbTest.report('idp_ranking', ab_test('idp_ranking'), request)
  end

  def is_in_idp_ranking_by_completion_group?
    ab_test('idp_ranking') == 'idp_ranking_by_completion'
  end
end
