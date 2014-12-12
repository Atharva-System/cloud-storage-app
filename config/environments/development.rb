Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = false


  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  FACEBOOK_APP_KEY = '321504088033036'
  FACEBOOK_APP_KEY_SECRET = 'd3d31c32153977b30560dd611503484a'
  DROPBOX_APP_KEY = 'pnft9gbg865x1md'
  DROPBOX_APP_KEY_SECRET = 'saqdnsx7gdrn7qr'
  DROPBOX_APP_MODE = :auto
  BOX_APP_KEY = 'l2d5je3y1qftp4veq7e28nuuxpe3jbxo'
  BOX_APP_KEY_SECRET = 'u24eWxs0RxCzxApY1yZbHhJL2alxRdpL'
end
