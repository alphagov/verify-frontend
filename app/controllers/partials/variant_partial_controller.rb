module VariantPartialController
  def current_identity_providers_for_loa_by_variant(variant)
    current_available_identity_providers_for_registration.select { |idp| ABC_VARIANTS_CONFIG["variant_#{variant}_idp_set"].include?(idp.simple_id) }
  end

  def segment_advice(segments)
    x = segments.map { |segment| ABC_VARIANTS_CONFIG["segment_advice"][segment] }
    x.flatten
  end
end
