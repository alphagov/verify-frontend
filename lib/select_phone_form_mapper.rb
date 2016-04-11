class SelectPhoneFormMapper
  def self.map(params)
    if params.has_key?('select_phone_form')
      params['select_phone_form']
    else
      Hash[params.map { |key, value| [lookup_key(key), value] }]
    end
  end

  def self.lookup_key(key)
    key == 'landline_phone' ? 'landline' : key
  end
end
