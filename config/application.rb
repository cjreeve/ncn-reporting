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

    config.i18n.default_locale = :en
    config.i18n.fallbacks = true


    # the safe params list for filters
    config.filter_params = [
      :group,
      :category,
      :dir,
      :label,
      :order,
      :problem,
      :region,
      :route,
      :state,
      :user]

    config.site_url = "http://ncn-reporting.herokuapp.com"

    config.dev_email = "cjreeve@gmail.com"

    config.coord_limits = { lng: [-11.0, 2.0], lat: [49.0, 61.0] }

  end
end
