class WillItWorkForMeController < ApplicationController
  protect_from_forgery except: :will_it_work_for_me

  def index
    @form = WillItWorkForMeForm.new({})
  end

  def will_it_work_for_me
    @form = WillItWorkForMeForm.new(params['will_it_work_for_me_form'] || {})
    if @form.valid?
      ANALYTICS_REPORTER.report(request, 'Can I be Verified Next')
      selected_evidence = IdpEligibility::EvidenceQueryStringParser.parse(request.query_string)
      redirect_to build_uri_with_evidence(redirect_path, selected_evidence)
    else
      flash.now[:errors] = @form.errors.full_messages.join(', ')
      render :index
    end
  end

private

  def build_uri_with_evidence(path, evidence)
    uri = URI(path)
    uri.query = IdpEligibility::EvidenceQueryStringBuilder.build(evidence)
    uri.to_s
  end

  def redirect_path
    if @form.resident_last_12_months?
      @form.above_age_threshold? ? choose_a_certified_company_path : why_might_this_not_work_for_me_path
    elsif @form.address_but_not_resident?
      may_not_work_if_you_live_overseas_path
    elsif @form.no_uk_address?
      will_not_work_without_uk_address_path
    else
      why_might_this_not_work_for_me_path
    end
  end
end
