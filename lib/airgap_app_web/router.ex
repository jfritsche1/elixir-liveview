defmodule AirgapAppWeb.Router do
  use AirgapAppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AirgapAppWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AirgapAppWeb do
    pipe_through :browser

    live "/", MapLive, :index
    get "/tiles/:z/:x/:y", TileController, :show
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:airgap_app, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AirgapAppWeb.Telemetry
    end
  end

  # API routes
  scope "/api", AirgapAppWeb do
    pipe_through :api
    
    post "/locations", LocationController, :create
    get "/locations", LocationController, :index
  end
end
