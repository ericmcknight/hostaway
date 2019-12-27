defmodule HostawayWeb.ListingsController do
    use HostawayWeb, :controller

    def index(conn, params) do
        {_, value} = JSONAPI.Listings.listings()
        render(conn, "index.json", result: Poison.decode!(value))
    end
 
    def show(conn, %{"listing_id" => listing_id}) do
        {_, value} = JSONAPI.Listings.listings(listing_id)
        render(conn, "index.json", result: Poison.decode!(value))
    end

    # def calendar(conn, %{"listing_id" => listing_id, "year" => year, "month" => month}) do
    #     {_, value} = JSONAPI.Calendar.calendar_by_year_month(listing_id, year, month)
    #     render(conn, "index.json", result: value)
    # end
    
    def calendar(conn, %{"listing_id" => listing_id, "start_date" => start_date, "end_date" => end_date}) do
        {_, value} = JSONAPI.Calendar.calendar(listing_id, start_date, end_date)
        render(conn, "index.json", result: value)
    end
end