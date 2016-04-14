class WillItWorkForMeFormMapper
  def self.map(params)
    if params.has_key?('will_it_work_for_me_form')
      return params['will_it_work_for_me_form']
    end
    params
  end
end
