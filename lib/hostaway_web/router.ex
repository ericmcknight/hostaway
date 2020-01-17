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
    get "/listings/:listing_id/price", ListingsController, :price

    post "/listings/:listing_id/reserve", ListingsController, :create_reservation
    options "/listings/:listing_id/reserve", ListingsController, :create_reservation

    put "/reservations/:reservation_id/pay", ListingsController, :pay_reservation

  end
end
