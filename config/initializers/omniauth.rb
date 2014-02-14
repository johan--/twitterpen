Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  provider :twitter, ENV["TWITTER_TOKEN"], ENV["TWITTER_SECRET"]
end
