defmodule Stripe.InvoiceService do
    use HTTPoison.Base
    require Logger


    def create_invoice_initial_payment(customer_id, due_date, email, phone) do
        url = "https://api.stripe.com/v1/customers"

        headers = [] 
        |> Keyword.put(:"Content-Type", "application/x-www-form-urlencoded")
        |> Keyword.put(:"Authorization", "Bearer " <> SettingsService.get_stripe_secret_key())


        body = URI.encode_query(%{
            "customer" => customer_id,
            "colleciton_method" => "send_invoice",
            "description" => "Second charge for the original reservation.",
            "due_date" => due_date,
            "email" => email,
            "phone" => phone})
        
        HTTPoison.post(url, body, headers)
        |> handle_response()
    end


    defp handle_response({:ok, %{status_code: 200, body: json}}) do
        response = Poison.decode!(json)

        intent = %Stripe.Invoice{
            customer_id: response["customer"],
            name: response[""],
        }

        {:ok, intent}
    end

    defp handle_response({:ok, %{body: json}}) do
        {:error, json}
    end
end