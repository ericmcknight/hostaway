defmodule HostawayWeb.ListingsController do
    use HostawayWeb, :controller
    require Logger

    def index(conn, _) do
        {success, value} = HostawayService.get_listings()
        render(conn, "index.json", %{success: success, result: value})
    end

    def show(conn, %{"listing_id" => listing_id}) do
        {success, value} = HostawayService.get_listing(listing_id)
        render(conn, "index.json", %{success: success, result: value})
    end
   
    def calendar(conn, %{"listing_id" => listing_id, "start_date" => start_date, "end_date" => end_date}) do
        {success, value} = HostawayService.get_calendars(listing_id, start_date, end_date)
        render(conn, "index.json", %{success: success, result: value})
    end
  
    def price(conn, %{"listing_id" => listing_id, "start_date" => start_date, "end_date" => end_date}) do
        {success, value} = HostawayService.get_price(listing_id, start_date, end_date)
        render(conn, "price.json", %{state: success, result: value})
    end

    def create_reservation(conn, %{"reservation" => reservation_params}) do
        {success, value} = HostawayService.create_reservation(reservation_params)
        render(conn, "reservation.json", %{success: success, result: value})
    end
end