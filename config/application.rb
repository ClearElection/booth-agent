require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Booth
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    def self.expand_refs(json)
      json.tap {
        JSON.recurse_proc json do |item|
          if Hash === item and uri = item['$ref']
            uri = URI.parse(uri)
            source = case uri.scheme
                    when nil then nil
                    when 'file' then Rails.root.join uri.path.sub(%r{^/}, '')
                    else uri
                    end
            if source
              item.delete '$ref'
              item.merge! expand_refs JSON.parse source.read
            end
          end
        end
      }
    end

    api_schema = expand_refs JSON.parse Rails.root.join("schema/api.schema.json").read()

    config.middleware.insert_after ActionDispatch::Static, "CatchMiddlewareErrors"
    config.middleware.use Committee::Middleware::RequestValidation, schema: api_schema, raise: true, strict: true
    config.middleware.use Committee::Middleware::ResponseValidation, schema: api_schema, raise: true
  end
end
