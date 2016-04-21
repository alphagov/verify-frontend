require 'select_phone_form_mapper'
require 'idp_eligibility/evidence_query_string_parser'
require 'idp_eligibility/evidence_query_string_builder'

class SelectPhoneController < ApplicationController
  protect_from_forgery except: :select_phone

  def index
    @form = SelectPhoneForm.new({})
  end

  def select_phone
    @form = SelectPhoneForm.new(SelectPhoneFormMapper.map(params))
    if @form.valid?
      ANALYTICS_REPORTER.report(request, 'Phone Next')
      selected_phone_evidence = @form.selected_evidence
      store_selected_evidence(phone: selected_phone_evidence)
      selected_evidence = selected_phone_evidence + IdpEligibility::EvidenceQueryStringParser.parse(request.query_string)
      if idp_eligibility_checker.any?(selected_evidence, available_idps)
        redirect_to build_uri_with_evidence(will_it_work_for_me_path, selected_evidence)
      else
        redirect_to build_uri_with_evidence(no_mobile_phone_path, selected_evidence)
      end
    else
      flash.now[:errors] = @form.errors.full_messages.join(', ')
      render :index
    end
  end

private

  def available_idps
    SESSION_PROXY.federation_info_for_session(cookies).idps.collect { |idp| idp['simpleId'] }
  end

  def build_uri_with_evidence(path, evidence)
    uri = URI(path)
    uri.query = IdpEligibility::EvidenceQueryStringBuilder.build(evidence)
    uri.to_s
  end

  def idp_eligibility_checker
    IDP_ELIGIBILITY_CHECKER
  end
end
