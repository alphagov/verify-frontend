Taxon = Struct.new(:name, :transactions) do
  def <=>(other)
    if name == default_taxon
      1
    elsif name == default_taxon
      -1
    else
      name.casecmp(other.name)
    end
  end

  def default_taxon
    Taxon.default_taxon
  end

  def self.default_taxon
    I18n.translate('hub.transaction_list.other_services')
  end
end
