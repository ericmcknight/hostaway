defmodule JSONAPI.Listings do
    use HTTPoison.Base
    require Logger
    
    def listings() do
        case JSONAPI.Authentication.auth() do
            {:error, json} -> {:error, json}
            {:ok, value} -> get_listings(JSONAPI.Settings.get_url() <> "listings/", value)
       end
    end

    def listings(listing_id) do
        case JSONAPI.Authentication.auth() do
            {:error, json} -> {:error, json}
            {:ok, value} -> get_listings(JSONAPI.Settings.get_url() <> "listings/" <> listing_id, value)
       end
    end


    defp get_listings(url, token) do
        headers = []
        |> Keyword.put(:"Content-Type", "application/json")
        |> Keyword.put(:"Authorization", token["token"])

        # Logger.debug("Token: " <> token["token"])

        get(url, headers)
        |> handle_response()
    end


    defp handle_response({:ok, %{status_code: 200, body: json}}) do
        {:ok, json}
    end

    defp handle_response({:ok, %{body: json}}) do
        {:error, json}
    end
end