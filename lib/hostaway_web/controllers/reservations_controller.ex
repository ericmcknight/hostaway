defmodule HostawayWeb.ReservationsController do
    use HostawayWeb, :controller
    require Logger

    def show(conn, %{"reservation_id" => reservation_id}) do
        {success, value} = HostawayService.get_reservation(reservation_id)
        render(conn, "reservation.json", %{success: success, result: value})
    end

    def pay(conn, %{"reservation_id" => reservation_id, "pricing" => params}) do
        {success, value} = HostawayService.pay_reservation(reservation_id, params)
        render(conn, "reservation.json", %{success: success, result: value})
    end
end