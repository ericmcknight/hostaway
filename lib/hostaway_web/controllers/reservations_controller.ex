defmodule HostawayWeb.ReservationsController do
    use HostawayWeb, :controller
    require Logger

    def show(conn, %{"reservation_id" => reservation_id}) do
        {success, value} = JSONAPI.ReservationService.reservation(reservation_id)
        render(conn, "reservation.json", %{success: success, result: value})
    end

    def pay(conn, %{"reservation_id" => reservation_id}) do
        {success, value} = JSONAPI.ReservationService.pay(reservation_id)
        render(conn, "reservation.json", %{success: success, result: value})
    end
end