defmodule HostawayWeb.Router do
  use HostawayWeb, :router

  pipeline :api do
    plug CORSPlug, origin: "*"
    # plug CORSPlug, origin: "http://localhost:4000"
    plug :accepts, ["json"]
  end

  scope "/api/v1", HostawayWeb do
    pipe_through :api

    get "/listings", ListingsController, :index
    get "/listings/:listing_id", ListingsController, :show
    get "/listings/:listing_id/calendar", ListingsController, :calendar

    get "/pricing", PricingController, :index

    post "/booking", BookingController, :create
  end
end
