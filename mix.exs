defmodule AirgapApp.MixProject do
  use Mix.Project

  def project do
    [
      app: :airgap_app,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {AirgapApp.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # Phoenix core
      {:phoenix, "~> 1.7.0"},
      {:phoenix_html, "~> 3.3"},
      {:phoenix_live_view, "~> 0.20.0"},
      {:phoenix_live_reload, "~> 1.4", only: :dev},
      {:phoenix_pubsub, "~> 2.1"},
      
      # Web server
      {:plug_cowboy, "~> 2.6"},
      {:jason, "~> 1.4"},
      
      # NATS client for Proto messages
      {:gnat, "~> 1.8"},
      
      # Protocol buffers
      {:protobuf, "~> 0.12.0"},
      
      # H3 hexagonal indexing
      {:h3, "~> 3.7"},
      
      # Asset building - Tailwind CSS and esbuild
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      
      # Development & Monitoring
      {:phoenix_live_dashboard, "~> 0.8"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      
      # Security
      {:plug_crypto, "~> 2.0"}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "assets.setup", "assets.build"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"]
    ]
  end
end
