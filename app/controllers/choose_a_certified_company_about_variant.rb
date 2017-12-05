module ChooseACertifiedCompanyAboutVariant
  def about
    simple_id = params[:company]
    matching_idp = current_identity_providers_for_loa.detect { |idp| idp.simple_id == simple_id }
    @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(matching_idp)
    if @idp.viewable?
      @recommended = IDP_RECOMMENDATION_GROUPER_VARIANT.recommended?(@idp, selected_evidence, current_identity_providers_for_loa, current_transaction_simple_id)
      render 'choose_a_certified_company/about'
    else
      render 'errors/404', status: 404
    end
  end
end
