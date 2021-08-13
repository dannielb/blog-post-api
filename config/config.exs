# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :blog_post_api,
  ecto_repos: [BlogPostApi.Repo]

# Configures the endpoint
config :blog_post_api, BlogPostApiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "3S58bt1rA95iGnueRwkWFSSl8B+VQYPoMWfdcmMcm0JA+2Y6wtvVkMPTcusR5KTC",
  render_errors: [view: BlogPostApiWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: BlogPostApi.PubSub,
  live_view: [signing_salt: "6/dKnkSu"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
