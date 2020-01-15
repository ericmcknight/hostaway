defmodule HostawayWeb.ListingsController do
    use HostawayWeb, :controller
    require Logger

    def index(conn, params) do
        {success, value} = JSONAPI.Listings.listings()
        render(conn, "index.json", %{success: success, result: value})
    end

    def show(conn, %{"listing_id" => listing_id}) do
        {success, value} = JSONAPI.Listings.listings(listing_id)
        render(conn, "index.json", %{success: success, result: value})
    end
   
    def calendar(conn, %{"listing_id" => listing_id, "start_date" => start_date, "end_date" => end_date}) do
        {success, value} = JSONAPI.Calendar.calendar(listing_id, start_date, end_date)
        render(conn, "index.json", %{success: success, result: value})
    end
  
    def price(conn, %{"listing_id" => listing_id, "start_date" => start_date, "end_date" => end_date}) do
        {success, value} = JSONAPI.Pricing.price(listing_id, start_date, end_date)
        render(conn, "price.json", %{state: success, result: value})
    end

    def create_reservation(conn, %{"reservation" => reservation_params}) do
        {success, value} = JSONAPI.BookingService.new_booking(reservation_params)
        render(conn, "reservations.json", %{success: success, result: value})
    end

    def pay_reservation(conn, %{"reservation" => reservation_params}) do
        {success, value} = JSONAPI.BookingService.new_booking(reservation_params)
        render(conn, "reservations.json", %{success: success, result: value})
    end
end