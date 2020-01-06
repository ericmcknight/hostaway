defmodule HostawayWeb.ListingsView do
    use HostawayWeb, :view

    def render("index.json", %{success: state, result: result}) do
        case state do
            :ok -> %{data: %{state: state, listings: result}}
            :error -> %{data: %{state: state, message: result}}
        end
    end
end