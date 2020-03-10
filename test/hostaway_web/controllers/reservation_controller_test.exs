defmodule HostawayWeb.InvoiceControllerTest do
    use ExUnit.Case
    require Timex
    require Logger

    test "Get reservation" do
        {status, reservation} = HostawayService.get_reservation("4954250")

        Logger.debug(reservation.hostaway_reservation_id)

        assert :ok == status
        assert String.equivalent?("4954250", reservation.hostaway_reservation_id)
    end

end
   