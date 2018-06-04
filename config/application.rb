require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module HerokuApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Make rails use SASS syntax instead of SCSS syntax.
    # Purely because I personally prefer the cleaner syntax
    config.sass.preferred_syntax = :sass

    # Would like to see content length for JSON
    # responses so we can use a real progress bar
    # in AngularJS
    config.middleware.use Rack::ContentLength
  end
end
