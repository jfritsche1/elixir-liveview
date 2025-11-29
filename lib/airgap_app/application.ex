defmodule AirgapApp.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AirgapAppWeb.Telemetry,
      {Phoenix.PubSub, name: AirgapApp.PubSub},
      # Start the NATS client
      {AirgapApp.NatsClient, []},
      # Start the endpoint
      AirgapAppWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: AirgapApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    AirgapAppWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
