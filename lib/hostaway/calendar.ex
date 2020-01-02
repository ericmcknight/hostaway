defmodule JSONAPI.Calendar do
    use HTTPoison.Base
    use Timex
    require Logger


    def calendar(listing_id, start_date, end_date) do
        case JSONAPI.Authentication.auth() do
            {:error, json} -> {:error, json}
            {:ok, token} -> get_calendar(listing_id, start_date, end_date, token)
        end
    end

    
    defp get_calendar(listing_id, start_date, end_date, token) do
        query_string = URI.encode_query([startDate: start_date, endDate: end_date])
        url = JSONAPI.Settings.get_url() <> "listings/#{listing_id}/calendar?" <> query_string

        headers = []
        |> Keyword.put(:"Content-Type", "application/json")
        |> Keyword.put(:"Authorization", token["token"])

        get(url, headers)
        |> handle_response()
    end


    defp handle_response({:ok, %{status_code: 200, body: json}}) do
        {:ok, map_calendar_days(json)}
    end

    defp map_calendar_days(json) do
        results = Poison.decode!(json)["result"]
        case Enum.empty?(results) do
            true -> %{}
            false -> 
                Enum.map(results, fn(day) ->
                %{
                    "date" => day["date"],
                    "is_available" => day["isAvailable"] == 1,
                    "price" => day["price"],
                    "minimum_stay" => day["minimumStay"]
                } 
                end)
        end
    end

    defp handle_response({:ok, %{body: json}}) do
        {:error, json}
    end
end