class SelectDocumentsFormMapper
  def self.map(params)
    result = params.dup
    if params.has_key?('select_documents_form')
      return params['select_documents_form']
    end
    result['no_documents'] = 'false' unless params.has_key?('no_documents')
    result
  end
end
