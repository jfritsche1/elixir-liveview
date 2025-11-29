import Config

config :airgap_app,
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :airgap_app, AirgapAppWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [html: AirgapAppWeb.ErrorHTML, json: AirgapAppWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: AirgapApp.PubSub,
  live_view: [signing_salt: "NpF3xR8K"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args: ~w(js/app.js 
      --bundle 
      --target=es2017 
      --outdir=../priv/static/assets 
      --external:/fonts/* 
      --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.3.0",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config
import_config "#{config_env()}.exs"
