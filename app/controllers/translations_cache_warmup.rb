class TranslationsCacheWarmup
  def warmup
    RP_DISPLAY_REPOSITORY.update_all_translations
    render json: {status: 200}
  end
end