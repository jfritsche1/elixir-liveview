defmodule AirgapAppWeb.MapLive do
  use AirgapAppWeb, :live_view
  alias AirgapApp.H3Service
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(AirgapApp.PubSub, "proto:updates")
      :timer.send_interval(5000, self(), :cleanup_old_markers)
    end

    {:ok,
     socket
     |> assign(:markers, %{})
     |> assign(:h3_cells, MapSet.new())
     |> assign(:selected_h3, nil)
     |> assign(:stats, %{total_markers: 0, active_cells: 0, last_update: nil})
     |> assign(:zoom_level, 10)
     |> assign(:show_sidebar, true)}
  end

  @impl true
  def handle_info({:proto_message, message}, socket) do
    marker = process_location_update(message)
    h3_polygon = H3Service.h3_to_polygon(marker.h3)
    
    markers = Map.put(socket.assigns.markers, marker.id, marker)
    h3_cells = MapSet.put(socket.assigns.h3_cells, marker.h3)

    {:noreply,
     socket
     |> assign(:markers, markers)
     |> assign(:h3_cells, h3_cells)
     |> update_stats()
     |> push_event("add_marker", marker)
     |> push_event("add_h3_cell", %{h3: marker.h3, polygon: h3_polygon})}
  end

  @impl true
  def handle_info(:cleanup_old_markers, socket) do
    now = System.system_time(:millisecond)
    five_minutes_ago = now - (5 * 60 * 1000)
    
    active_markers = 
      socket.assigns.markers
      |> Enum.filter(fn {_id, marker} -> 
        Map.get(marker, :timestamp, now) > five_minutes_ago 
      end)
      |> Enum.into(%{})

    {:noreply, assign(socket, :markers, active_markers)}
  end

  @impl true
  def handle_event("map_click", %{"lat" => lat, "lng" => lng}, socket) do
    resolution = H3Service.zoom_to_h3_resolution(socket.assigns.zoom_level)
    h3_index = H3Service.point_to_h3(lat, lng, resolution)
    h3_polygon = H3Service.h3_to_polygon(h3_index)
    neighbors = H3Service.get_neighbors(h3_index)
    
    neighbor_polygons = Enum.map(neighbors, &H3Service.h3_to_polygon/1)
    
    {:noreply, 
     socket
     |> assign(:selected_h3, h3_index)
     |> push_event("highlight_h3", %{
       polygon: h3_polygon,
       neighbors: neighbor_polygons
     })}
  end

  @impl true
  def handle_event("zoom_changed", %{"zoom" => zoom}, socket) do
    {:noreply, assign(socket, :zoom_level, zoom)}
  end

  @impl true
  def handle_event("toggle_sidebar", _, socket) do
    {:noreply, assign(socket, :show_sidebar, !socket.assigns.show_sidebar)}
  end

  @impl true
  def handle_event("clear_markers", _, socket) do
    {:noreply, 
     socket
     |> assign(:markers, %{})
     |> assign(:h3_cells, MapSet.new())
     |> push_event("clear_map", %{})}
  end

  defp process_location_update(message) do
    lat = Map.get(message, :latitude, 0.0)
    lon = Map.get(message, :longitude, 0.0)
    
    %{
      id: Map.get(message, :id, UUID.uuid4()),
      lat: lat,
      lon: lon,
      h3: H3Service.point_to_h3(lat, lon),
      timestamp: Map.get(message, :timestamp, System.system_time(:millisecond)),
      metadata: Map.get(message, :metadata, %{})
    }
  end

  defp update_stats(socket) do
    update(socket, :stats, fn _ ->
      %{
        total_markers: map_size(socket.assigns.markers),
        active_cells: MapSet.size(socket.assigns.h3_cells),
        last_update: DateTime.utc_now()
      }
    end)
  end

  defp format_timestamp(timestamp) when is_integer(timestamp) do
    timestamp
    |> DateTime.from_unix!(:millisecond)
    |> Calendar.strftime("%H:%M:%S")
  end
  defp format_timestamp(_), do: "N/A"
end
