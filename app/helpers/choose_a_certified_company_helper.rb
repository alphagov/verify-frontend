module ChooseACertifiedCompanyHelper
  def recommended_company_message(count)
    t 'hub.choose_a_certified_company.idp_count_html', company_count_html: company_count_message(count)
  end

private

  def company_count_message(count)
    case count
    when 0
      t('hub.choose_a_certified_company.zero_companies_html')
    when 1
      t('hub.choose_a_certified_company.one_company_html')
    else
      t('hub.choose_a_certified_company.multiple_companies_html', count: count)
    end
  end
end
