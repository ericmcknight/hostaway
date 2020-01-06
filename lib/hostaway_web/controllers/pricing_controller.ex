defmodule HostawayWeb.PricingController do
    use HostawayWeb, :controller
    require Logger

    def index(conn, %{"listing_id" => listing_id, "start_date" => start_date, "end_date" => end_date}) do
        {success, value} = JSONAPI.Pricing.price(listing_id, start_date, end_date)
        render(conn, "index.json", %{state: success, result: value})
    end
end