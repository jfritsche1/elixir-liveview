defmodule AirgapAppWeb.LocationController do
  use AirgapAppWeb, :controller
  alias AirgapApp.NatsClient

  def create(conn, %{"location" => location_params}) do
    # Publish location update to NATS
    message = %{
      id: location_params["id"] || UUID.uuid4(),
      latitude: location_params["latitude"],
      longitude: location_params["longitude"],
      timestamp: location_params["timestamp"] || System.system_time(:millisecond),
      metadata: location_params["metadata"] || %{}
    }
    
    case NatsClient.publish("location.updates", message) do
      :ok ->
        conn
        |> put_status(:created)
        |> json(%{status: "success", message: "Location update published"})
      
      {:error, reason} ->
        conn
        |> put_status(:service_unavailable)
        |> json(%{status: "error", message: "Failed to publish: #{inspect(reason)}"})
    end
  end

  def index(conn, params) do
    # For demo purposes, return empty array
    # In production, you might query a database or cache
    limit = String.to_integer(params["limit"] || "100")
    
    locations = []
    
    conn
    |> json(%{
      locations: locations,
      count: length(locations),
      limit: limit
    })
  end
end
