# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :social_web, SocialWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  # secret_key_base: "eHVJjdZ2T1G5eYw3dRO2vXNAQUFrgXOAJgAALwpxkHu34YoIodGt3r/Mw8bzu9Nx",
  render_errors: [view: SocialWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: SocialWeb.PubSub,
           adapter: Phoenix.PubSub.PG2]
# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :hackney,
  max_connections: 120
# Configures cronjob
config :quantum, social_web: [
    cron: [
      update_post: [
        schedule: "*/5 * * * *",
        task: "SocialWeb.ScheduledTask.update_post"
      ],
      adjust_trust_hot: [
        schedule: "@daily",
        task: "SocialWeb.ScheduledTask.adjust_trust_hot"
      ]
    ]
  ]
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
