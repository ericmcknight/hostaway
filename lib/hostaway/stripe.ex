defmodule JSONAPI.Stripe do
    use HTTPoison.Base
    require Logger

    def get_client_secret_key(amount) do
        url = "https://api.stripe.com/v1/payment_intents"

        headers = [] 
        |> Keyword.put(:"Content-Type", "application/x-www-form-urlencoded")
        |> Keyword.put(:"Authorization", "Bearer sk_test_fDhVyQPAasAg0lAZiXC10S3B000ijtctiU")
 
        body = URI.encode_query(%{
            "amount" => 1099, # amount, 
            "currency" => "usd"})
        
        HTTPoison.post(url, body, headers)
        |> handle_response()
    end

    defp handle_response({:ok, %{status_code: 200, body: json}}) do
        stripe_response = Poison.decode!(json)
        client_secret = stripe_response["client_secret"]
        {:ok, %{"client_secret" => client_secret}}
    end

    defp handle_response({:ok, %{body: json}}) do
        {:error, json}
    end
end