defmodule Stripe.PaymentIntentService do
    use HTTPoison.Base
    require Logger


    def create_payment_intent(amount) do
        url = SettingsService.get_stripe_url() <> "/payment_intents"

        headers = [] 
        |> Keyword.put(:"Content-Type", "application/x-www-form-urlencoded")
        |> Keyword.put(:"Authorization", "Bearer " <> SettingsService.get_stripe_secret_key())
 
        body = URI.encode_query(%{
            "amount" => Kernel.trunc(amount * 100), # 1099,
            "currency" => "usd"})
        
        HTTPoison.post(url, body, headers)
        |> handle_response()
    end

    defp handle_response({:ok, %{status_code: 200, body: json}}) do
        stripe_response = Poison.decode!(json)

        intent = %Stripe.PaymentIntent{
            client_secret_key: stripe_response["client_secret"]
        }

        {:ok, intent}
    end

    defp handle_response({:ok, %{body: json}}) do
        {:error, json}
    end
end