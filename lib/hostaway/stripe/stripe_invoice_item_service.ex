defmodule Stripe.InvoiceItemService do
    use HTTPoison.Base
    require Logger


    def create_invoice_item(invoice, amount) do
        request = %Stripe.InvoiceItemRequest{
            invoice_id: invoice.id,
            currency: invoice.currency,
            customer_id: invoice.customer_id,
            amount: amount * 100,
            description: "Rental Fee",
        }

        create_item(request)
    end



    defp create_item(request) do
        url = "https://api.stripe.com/v1/invoiceitems"

        headers = [] 
        |> Keyword.put(:"Content-Type", "application/x-www-form-urlencoded")
        |> Keyword.put(:"Authorization", "Bearer " <> SettingsService.get_stripe_secret_key())

        body = URI.encode_query(%{
            "invoice" => request.customer_id,
            "colleciton_method" => request.collection_method,
            "description" => request.description,
            "due_date" => request.due_date})
        
        HTTPoison.post(url, body, headers)
        |> handle_response() 
    end

    defp handle_response({:ok, %{status_code: 200, body: json}}) do
        response = Poison.decode!(json)

        item = %Stripe.InvoiceItem{
            id: response["id"],
            amount: response["amount"],
            currency: response["currency"],
            customer_id: response["customer"],
            description: response["description"],
            invoice_id: response["invoice"],
        }

        {:ok, item}
    end

    defp handle_response({:ok, %{body: json}}) do
        {:error, json}
    end
end