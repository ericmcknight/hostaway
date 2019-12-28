defmodule HostawayWeb.Router do
  use HostawayWeb, :router

  pipeline :api do
    plug CORSPlug, origin: ["http://localhost:4000", "https://gentle-basin-37816.herokuapp.com/"]
    plug :accepts, ["json"]
  end

  scope "/api/v1", HostawayWeb do
    pipe_through :api

    get "/auth", AuthController, :index
    
    get "/listings", ListingsController, :index
    get "/listings/:listing_id", ListingsController, :show
    get "/listings/:listing_id/calendar", ListingsController, :calendar
  end
end
