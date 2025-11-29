defmodule AirgapAppWeb.TileController do
  use AirgapAppWeb, :controller

  def show(conn, %{"z" => z, "x" => x, "y" => y}) do
    tile_path = Path.join(["priv", "static", "tiles", z, x, "#{y}.png"])
    absolute_path = Path.join(Application.app_dir(:airgap_app), tile_path)
    
    if File.exists?(absolute_path) do
      conn
      |> put_resp_content_type("image/png")
      |> put_resp_header("cache-control", "public, max-age=31536000")
      |> send_file(200, absolute_path)
    else
      # Return a blank tile or default image
      send_blank_tile(conn)
    end
  end

  defp send_blank_tile(conn) do
    # Create a simple 256x256 transparent PNG in memory
    # In production, you might want to serve a default tile image
    blank_png = <<
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,  # PNG signature
      0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,  # IHDR chunk
      0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x00,  # 256x256
      0x01, 0x00, 0x00, 0x00, 0x00, 0x37, 0x6E, 0xF9,  # 1-bit grayscale
      0x24, 0x00, 0x00, 0x00, 0x10, 0x49, 0x44, 0x41,  # IDAT chunk
      0x54, 0x78, 0x9C, 0x62, 0x00, 0x00, 0x00, 0x00,  # Compressed data
      0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
      0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,  # IEND chunk
      0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
    >>
    
    conn
    |> put_resp_content_type("image/png")
    |> put_resp_header("cache-control", "no-cache")
    |> send_resp(200, blank_png)
  end
end
