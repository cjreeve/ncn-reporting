require File.expand_path('../boot', __FILE__)

require 'csv'
require 'gpx'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Workspace
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'London'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de


    # DEPRECATION WARNING: Currently, Active Record suppresses errors raised within `after_rollback`/`after_commit` callbacks and only print them to the logs. In the next version, these errors will no longer be suppressed. Instead, the errors will propagate normally just like in other Active Record callbacks.
    # You can opt into the new behavior and remove this warning by setting:
    # config.active_record.raise_in_transactional_callbacks = true


    config.i18n.default_locale = :en
    config.i18n.fallbacks = true


    # the safe params list for filters
    config.filter_params = [
      :area,
      :group,
      :category,
      :dir,
      :label,
      :order,
      :problem,
      :region,
      :route,
      :state,
      :user,
      :role,
      :query,
      :admin,
      :locked,
      :per_page]

    config.site_url = "https://ncn-reporting.herokuapp.com"

    config.dev_email = "cjreeve@gmail.com"

    config.coord_limits = { lng: [-11.0, 2.0], lat: [49.0, 61.0] }

    config.comments_per_page = 7

    config.enable_issue_reporting_prompt = true

  end
end

Raven.configure do |config|
  config.dsn = 'https://91b6f82197684cf092c12b923fa8707e:16b2384500e94ec099e1478dc2ebc331@sentry.io/4068198'
end
