defmodule HostawayWeb.PricingView do
    use HostawayWeb, :view

    def render("index.json", %{result: listings}) do
        %{data: listings}
    end
end