OmniAuth.config.logger = Rails.logger
OmniAuth.config.on_failure = SessionsController.action(:oauth_failure)

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, FACEBOOK_APP_KEY, FACEBOOK_APP_KEY_SECRET, {:client_options => {:ssl => {:ca_file => Rails.root.join("cacert.pem").to_s}}}
end