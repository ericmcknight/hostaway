# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

use Mix.Config

# General application configuration
config :hostaway,
  namespace: HostawayWeb,
  hostaway_url: "https://api.hostaway.com/v1/",
  hostaway_grant_type: {:system, :string, "GRANT_TYPE"},
  hostaway_client_id: {:system, :string, "CLIENT_ID"},
  hostaway_client_secret: {:system, :string, "CLIENT_SECRET"},
  hostaway_scope: {:system, :string, "SCOPE"},
  stripe_publishable_key: {:system, :string, "STRIPE_PUBLISHABLE_KEY"},
  stripe_secret_key: {:system, :string, "STRIPE_PRIVATE_KEY"}

# CORS configuration
# config :cors_plug,
#   # origin: [{:system, :string, "CORS_URL"}],
#   origin: ["http://localhost:4000"],
#   max_age: 86400,
#   methods: ["GET", "POST"]

# money configuration
config :money,
  default_currency: :USD,
  separator: ",",
  delimiter: ".",
  symbol: false,
  symbol_on_right: false,
  symbol_space: false,
  fractional_unit: true,
  strip_insignificant_zeros: false


# Configures the endpoint
config :hostaway, HostawayWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "kE0ZBM2k+0AJSGR9eaAyf4KUv1b4vFA8EL1+WD5QuGDL+i4EP70PlV1a1QXltyx9",
  render_errors: [view: HostawayWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Hostaway.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
