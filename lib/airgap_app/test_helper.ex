defmodule AirgapApp.TestHelper do
  @moduledoc """
  Helper functions for testing and sending test messages
  """
  
  alias AirgapApp.NatsClient
  
  @doc """
  Send a test location update via NATS
  """
  def send_location_update(attrs \\ %{}) do
    message = Map.merge(%{
      id: "test_#{:rand.uniform(10000)}",
      latitude: 40.7128 + (:rand.uniform() - 0.5) * 0.1,
      longitude: -74.0060 + (:rand.uniform() - 0.5) * 0.1,
      timestamp: System.system_time(:millisecond),
      altitude: 100.0,
      speed: 15.0,
      heading: :rand.uniform(360),
      accuracy: 5.0,
      source: "TEST",
      metadata: %{
        "type" => "vehicle",
        "status" => "active"
      }
    }, attrs)
    
    NatsClient.publish("location.updates", message)
  end
  
  @doc """
  Send multiple test location updates
  """
  def send_multiple_updates(count \\ 10, delay_ms \\ 100) do
    Task.start(fn ->
      Enum.each(1..count, fn i ->
        send_location_update(%{
          id: "vehicle_#{i}",
          latitude: 40.7128 + (:rand.uniform() - 0.5) * 0.2,
          longitude: -74.0060 + (:rand.uniform() - 0.5) * 0.2
        })
        Process.sleep(delay_ms)
      end)
    end)
  end
  
  @doc """
  Simulate moving vehicle
  """
  def simulate_moving_vehicle(id \\ "vehicle_sim", duration_seconds \\ 60) do
    Task.start(fn ->
      start_lat = 40.7128
      start_lon = -74.0060
      
      Enum.each(1..duration_seconds, fn i ->
        # Simulate movement
        lat = start_lat + (i / duration_seconds) * 0.01
        lon = start_lon + (i / duration_seconds) * 0.01
        
        send_location_update(%{
          id: id,
          latitude: lat,
          longitude: lon,
          speed: 10.0 + :rand.uniform() * 5,
          heading: 45.0
        })
        
        Process.sleep(1000)
      end)
    end)
  end
end
