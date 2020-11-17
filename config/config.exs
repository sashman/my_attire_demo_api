# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :my_attire_demo_api, MyAttireDemoApiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "6PYGiJagDHVoJxdNYXgW48bq7MdKsK7HDmYn0UQMAe4XjfcRcyOWZ5J1y9b8G76b",
  render_errors: [view: MyAttireDemoApiWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: MyAttireDemoApi.PubSub,
  live_view: [signing_salt: "kWvFvA9O"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :elasticsearch_elixir_bulk_processor,
  error_function: &MyAttireDemoApi.DataUpload.Bulk.on_error/1,
  success_function: &MyAttireDemoApi.DataUpload.Bulk.on_success/1,
  retry_function: &MyAttireDemoApi.DataUpload.Bulk.retry/0

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
