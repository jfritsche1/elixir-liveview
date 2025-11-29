defmodule AirgapApp.H3Service do
  @moduledoc """
  Service for H3 hexagonal hierarchical geospatial indexing operations
  """
  
  @default_resolution 9

  def point_to_h3(lat, lon, resolution \\ @default_resolution) do
    :h3.from_geo({lat, lon}, resolution)
  end

  def h3_to_polygon(h3_index) do
    boundary = :h3.to_geo_boundary(h3_index)
    Enum.map(boundary, fn {lat, lon} -> [lon, lat] end)
  end

  def get_neighbors(h3_index, k \\ 1) do
    :h3.k_ring(h3_index, k)
  end

  def h3_to_center(h3_index) do
    {lat, lon} = :h3.to_geo(h3_index)
    %{lat: lat, lon: lon, h3: h3_index}
  end

  def calculate_coverage(points, resolution \\ @default_resolution) do
    points
    |> Enum.map(fn {lat, lon} -> :h3.from_geo({lat, lon}, resolution) end)
    |> Enum.uniq()
    |> Enum.map(&h3_to_polygon/1)
  end

  def get_cells_in_bbox({min_lat, min_lon, max_lat, max_lon}, resolution \\ @default_resolution) do
    polygon = [
      {min_lat, min_lon},
      {min_lat, max_lon},
      {max_lat, max_lon},
      {max_lat, min_lon},
      {min_lat, min_lon}
    ]
    
    :h3.polyfill(polygon, resolution)
  end

  def h3_distance(h3_index1, h3_index2) do
    :h3.distance(h3_index1, h3_index2)
  end

  def zoom_to_h3_resolution(zoom_level) do
    cond do
      zoom_level <= 3 -> 1
      zoom_level <= 5 -> 2
      zoom_level <= 6 -> 3
      zoom_level <= 7 -> 4
      zoom_level <= 8 -> 5
      zoom_level <= 9 -> 6
      zoom_level <= 10 -> 7
      zoom_level <= 11 -> 8
      zoom_level <= 12 -> 9
      zoom_level <= 13 -> 10
      zoom_level <= 14 -> 11
      zoom_level <= 15 -> 12
      zoom_level <= 16 -> 13
      zoom_level <= 17 -> 14
      true -> 15
    end
  end

  def h3_to_string(h3_index) when is_integer(h3_index) do
    Integer.to_string(h3_index, 16)
  end

  def h3_to_string(h3_index), do: to_string(h3_index)

  def string_to_h3(h3_string) when is_binary(h3_string) do
    String.to_integer(h3_string, 16)
  end
end
