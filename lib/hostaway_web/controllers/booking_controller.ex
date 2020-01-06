defmodule HostawayWeb.BookingController do
    use HostawayWeb, :controller
    require Logger

    def create(conn, %{"booking" => booking_params}) do
        {success, value} = JSONAPI.BookingService.new_booking(booking_params)
        render(conn, "index.json", %{success: success, result: value})
    end
end