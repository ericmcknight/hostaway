defmodule HostawayWeb.PricingView do
    use HostawayWeb, :view

    def render("index.json", %{state: state, result: result}) do
        case state do
            :ok -> %{data: %{state: state, price: result}}
            :error -> %{data: %{state: state, message: result}}
        end
    end
end