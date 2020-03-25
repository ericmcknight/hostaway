defmodule CalendarService do
    use HTTPoison.Base
    use Timex
    require Logger


    def get_calendars(listing_id, start_date, end_date) do
        case AuthenticationService.auth() do
            {:error, json}  -> {:error, json}
            {:ok, token}    -> get_calendars(listing_id, start_date, end_date, token)
        end
    end

    def get_calendars(listing_id, start_date, end_date, token) do
        case validate_dates(start_date, end_date) do
            {:error, term} -> {:error, term}
            {:ok} -> get_calendar(listing_id, start_date, end_date, token)
        end
    end


    defp validate_dates(start_date, end_date) do
        case validate_date_text(start_date, "Start date") do
            {:error, term} -> {:error, term}
            {:ok} -> 
                case validate_date_text(end_date, "End date") do
                    {:error, term} -> {:error, term}
                    {:ok}          -> {:ok}
                end
        end
    end

    defp validate_date_text(text, label) do
        {status, date} = parse_date_text(text)
        if :error == status do
            {:error, label <> " cannot be parsed"}
        else 
            # if is_less_than_today(date) do
            #     {:error, label <> " cannot be less than today."}
            # else 
            {:ok}
            # end 
        end
    end

    def parse_date_text(text) do
        Timex.parse(text, "{YYYY}-{0M}-{0D}") 
    end

    def is_less_than_today(datetime) do
        case Timex.compare(Timex.local(), datetime, :day) do
            1   -> true 
            0   -> false
            -1  -> false 
        end
    end


    defp get_calendar(listing_id, start_date, end_date, token) do
        query_string = URI.encode_query([startDate: start_date, endDate: end_date])
        url = SettingsService.get_url() <> "listings/#{listing_id}/calendar?" <> query_string

        headers = []
        |> Keyword.put(:"Content-Type", "application/json")
        |> Keyword.put(:"Authorization", token["token"])

        get(url, headers)
        |> handle_response()
    end

    defp handle_response({:ok, %{status_code: 200, body: json}}) do
        {:ok, map_calendar_days(json)}
    end

    defp handle_response({:ok, %{body: json}}) do
        {:error, json}
    end

    defp map_calendar_days(json) do
        # Logger.debug(json)
        results = Poison.decode!(json)["result"]
        case Enum.empty?(results) do
            true -> %{}
            false -> 
                Enum.map(results, fn(day) ->
                %{
                    "date" => day["date"] <> "T14:00:00Z",
                    "is_available" => day["isAvailable"] == 1,
                    "price" => day["price"],
                    "minimum_stay" => day["minimumStay"]
                } 
                end)
        end
    end

end