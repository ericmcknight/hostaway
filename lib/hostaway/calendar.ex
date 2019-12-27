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


    # def calendar_by_year_month(listing_id, year, month, is_available) do
    #     case JSONAPI.Authentication.auth() do
    #         {:error, json} -> {:error, json}
    #         {:ok, token} -> 
    #             {yearInt, _} = Integer.parse(year)
    #             {monthInt, _} = Integer.parse(month)
    #             start_date = get_date_text(Timex.beginning_of_month(yearInt, monthInt))
    #             end_date = get_date_text(Timex.end_of_month(yearInt, monthInt))
    #             get_calendar(listing_id, start_date, end_date, token)
    #     end
    # end

    # defp get_date_text(result) do
    #     case result do
    #         {:error, _} -> {:error}
    #         _ -> 
    #             {success, text} = Timex.format(result, "{YYYY}-{0M}-{0D}")
    #             text
    #     end
    # end


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
        filtered = Enum.filter(Poison.decode!(json)["result"], fn(elem) -> elem["isAvailable"] == 0 end)
        case Enum.empty?(filtered) do
            true -> %{}
            false -> 
                Enum.map(filtered, fn(day) ->
                %{
                    "date" => day["date"],
                    "isAvailable" => day["isAvailable"] == 1,
                    "price" => day["price"]
                } 
                end)
        end
    end

    # defp is_date_available(date, is_available) do
    #     # Logger.debug(isAvailable)
    #     case Timex.parse(date, "{YYYY}-{M}-{D}") do
    #         {:error, _} -> false
    #         {:ok, date} -> is_available == 1
    #     end
    # end


    defp handle_response({:ok, %{body: json}}) do
        {:error, json}
    end
end