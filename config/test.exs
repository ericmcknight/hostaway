use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :hostaway, HostawayWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :debug

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