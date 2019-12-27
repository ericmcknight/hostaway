defmodule HostawayWeb.AuthView do
    use HostawayWeb, :view

    def render("index.json", %{result: auth}) do
        %{data: auth}
    end
end