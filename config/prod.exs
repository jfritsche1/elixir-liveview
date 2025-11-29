import Config

# For production, don't check origin
config :airgap_app, AirgapAppWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json",
  check_origin: false

# Do not print debug messages in production
config :logger, level: :info

# Runtime production config is in runtime.exs
