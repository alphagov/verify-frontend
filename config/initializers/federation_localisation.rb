
Rails.application.config.i18n.load_path +=  Dir[File.join(CONFIG.rp_display_locales, '*.{rb,yml}').to_s]
Rails.application.config.i18n.load_path +=  Dir[File.join(CONFIG.idp_display_locales, '*.{rb,yml}').to_s]
