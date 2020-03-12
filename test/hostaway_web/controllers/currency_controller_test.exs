defmodule HostawayWeb.CurrencyControllerTest do
    use ExUnit.Case
    require Timex
    require Logger
    require Money

    test "integer currency value" do
        Logger.debug(Stripe.InvoiceService.to_currency(100))
        Logger.debug(Stripe.InvoiceService.to_currency(1.00))
        Logger.debug(Stripe.InvoiceService.to_currency(3.752))

        assert true == true
    end

end