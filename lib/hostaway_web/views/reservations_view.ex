defmodule HostawayWeb.ReservationsView do
    use HostawayWeb, :view

    def render("reservation.json", %{success: state, result: result}) do
        case state do
            :ok -> %{data: %{state: state, reservation: result}}
            :error -> %{data: %{state: state, message: result}}
        end
    end
end