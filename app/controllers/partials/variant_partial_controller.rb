module VariantPartialController
  def current_identity_providers_for_loa_by_variant(_variant)
    current_available_identity_providers_for_registration
  end

  def segment_advice(segments)
    x = segments.map { |segment| ABC_VARIANTS_CONFIG["segment_advice"][segment] }
    x.flatten
  end
end
