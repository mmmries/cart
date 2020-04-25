# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :dash, DashWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "PV1oONoLrbzd1hti6SaMB7RFk1pIfTYcAmiRjT0O5EI1cew3K9gQs6bu+JkLak2j",
  render_errors: [view: DashWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Dash.PubSub,
  live_view: [signing_salt: "qVbU16H8"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
