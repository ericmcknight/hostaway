defmodule Stripe.InvoiceItemService do
    use HTTPoison.Base
    require Logger


    def create_invoice_item(customer_id, amount, description) do
        request = %Stripe.InvoiceItemRequest{
            # invoice_id: invoice.id,
            currency: "usd",
            customer_id: customer_id,
            amount: Kernel.trunc(amount * 100),
            description: description,
        }

        create_item(request)
    end

    defp create_item(request) do
        url = SettingsService.get_stripe_url() <> "/invoiceitems"

        headers = [] 
        |> Keyword.put(:"Content-Type", "application/x-www-form-urlencoded")
        |> Keyword.put(:"Authorization", "Bearer " <> SettingsService.get_stripe_secret_key())

        body = URI.encode_query(%{
            "currency" => request.currency,
            "customer" => request.customer_id,
            "amount" => request.amount,
            "description" => request.description})
        
        HTTPoison.post(url, body, headers)
        |> handle_create_response() 
    end

    defp handle_create_response({:ok, %{status_code: 200, body: json}}) do
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

    defp handle_create_response({:ok, %{body: json}}) do
        {:error, json}
    end



    
    def delete_invoice_item(item_id) do
       url = SettingsService.get_stripe_url() <> "/invoiceitems/" <> item_id

        headers = [] 
        |> Keyword.put(:"Content-Type", "application/x-www-form-urlencoded")
        |> Keyword.put(:"Authorization", "Bearer " <> SettingsService.get_stripe_secret_key())

        HTTPoison.delete(url, headers)
        |> handle_delete_response() 
    end

    defp handle_delete_response({:ok, %{status_code: 200, body: json}}) do
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

    defp handle_delete_response({:ok, %{body: json}}) do
        {:error, json}
    end
end