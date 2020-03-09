defmodule JSONAPI.Stripe do
    use HTTPoison.Base
    require Logger


    def create_payment_intent(amount) do
        url = "https://api.stripe.com/v1/payment_intents"

        headers = [] 
        |> Keyword.put(:"Content-Type", "application/x-www-form-urlencoded")
        |> Keyword.put(:"Authorization", "Bearer " <> JSONAPI.Settings.get_stripe_secret_key())
 
        body = URI.encode_query(%{
            "amount" => Kernel.trunc(amount * 100), # 1099,
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