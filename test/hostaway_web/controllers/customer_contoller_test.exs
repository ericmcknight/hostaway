defmodule HostawayWeb.CustomerControllerTest do
    use ExUnit.Case
    require Timex
    require Logger

    test "Create customer in Stripe" do
        name = "Eric McKnight"
        email = "mail@email.com"
        phone = "678 245 7897"

        {status, customer} = StripeService.create_customer(name, email, phone)
        assert :ok == status

        {delete, _} = StripeService.delete_customer(customer.id)
        assert :ok == delete
    end

end
   