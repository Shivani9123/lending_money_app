require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LendingMoneyApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    Sidekiq.configure_server do |config|
      config.on(:startup) do
        schedule_file = Rails.root.join("config/sidekiq.yml")

        if File.exist?(schedule_file)
          schedule_data = YAML.load_file(schedule_file)
          schedule = schedule_data[:schedule] || schedule_data["schedule"]

          if schedule.is_a?(Hash)
            Sidekiq::Scheduler.dynamic = true
            Sidekiq::Scheduler.load_schedule!(schedule)
          else
            Rails.logger.warn("Sidekiq schedule is not a Hash: #{schedule.inspect}")
          end
        else
          Rails.logger.warn("Sidekiq schedule file not found at #{schedule_file}")
        end
      end
    end
  end
end
