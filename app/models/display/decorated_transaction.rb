require 'display/rp_display_data'
module Display
  class DecoratedTransaction < DelegateClass(RpDisplayData)
    attr_reader :display_data, :transaction
    delegate :homepage, :loa_list, to: :transaction

    def initialize(display_data, transaction, homepage_enabled = true)
      @display_data = display_data
      super(display_data)
      @transaction = transaction
      @homepage_enabled = homepage_enabled
    end

    def ==(other)
      @transaction == other.transaction && @display_data == other.display_data
    end

    def taxon
      if homepage?
        @display_data.taxon
      else
        default_taxon
      end
    end

    def homepage?
      @homepage_enabled && homepage.present?
    end

    def <=>(other)
      raise "Incompatible other error" if !other.is_a?(DecoratedTransaction)
      name.casecmp(other.name)
    end
  end
end
