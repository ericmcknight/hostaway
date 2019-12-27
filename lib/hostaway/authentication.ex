defmodule JSONAPI.Authentication do
    use HTTPoison.Base
    
    def auth() do
        url = JSONAPI.Settings.get_url() <> "accessTokens"

        headers = [] 
        |> Keyword.put(:"Content-Type", "application/x-www-form-urlencoded")
        |> Keyword.put(:"Access-Control-Allow-Origin", "http://localhost")
        |> Keyword.put(:"Access-Control-Allow-Credentials", true)

        body = URI.encode_query(%{
            "grant_type" => get_grant_type(), 
            "client_id" => get_client_id(), 
            "client_secret" => get_client_secret(), 
            "scope" => get_scope()})
        
        HTTPoison.post(url, body, headers)
        |> handle_response()
    end

    defp handle_response({:ok, %{status_code: 200, body: json}}) do
        token = Poison.decode!(json)
        bearer = token["token_type"] <> " " <> token["access_token"]
        {:ok, %{"token" => bearer}}
    end

    defp handle_response({:ok, %{body: json}}) do
        {:error, json}
    end

    defp handle_response({:error, reason}) do
        msg = "Http error from hostaway.com. " <> reason
        {:error, msg}
    end


    defp get_grant_type() do
        Confex.fetch_env!(:hostaway, :hostaway_grant_type)
    end

    defp get_client_id() do
        Confex.fetch_env!(:hostaway, :hostaway_client_id)
    end

    defp get_client_secret() do
        Confex.fetch_env!(:hostaway, :hostaway_client_secret)
    end

    defp get_scope() do
        Confex.fetch_env!(:hostaway, :hostaway_scope)
    end
end