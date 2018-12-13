module RedirectToIdpWarningHelper
  def other_ways(idp)
    requirement_text = idp.no_docs_requirement
    if requirement_text.empty?
      return ''
    end

    link_text = t('hub.redirect_to_idp_warning.other_ways_link', transaction: other_ways_description)
    link = link_to(link_text, other_ways_to_access_service_path, id: 'choose_other_ways')
    t('hub.redirect_to_idp_warning.no_docs_other_ways_message_html', idp_no_docs_requirement: requirement_text, other_ways_link: link)
  end
end
