defmodule HostawayWeb.InvoiceControllerTest do
    use ExUnit.Case
    require Timex
    require Logger

    test "Create invoice in Stripe" do
        reservationId = "1000"
        name = "Eric McKnight"
        email = "mail@email.com"
        phone = "678 245 7897"

        {status, customer} = StripeService.create_customer(reservationId, name, email, phone)
        assert :ok == status

        {delete, result} = StripeService.delete_customer(customer.id)
        assert :ok == delete
    end

end
   