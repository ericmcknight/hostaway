defmodule Stripe.InvoiceService do
    use HTTPoison.Base
    require Logger


    def create_invoice_initial_payment(reservation, listing, pricing) do
        request = %Stripe.InvoiceRequest{
            customer_id: reservation.stripe_customer_id,
            collection_method: "send_invoice",
            description: build_description(listing, pricing),
            due_date: nil,
        }

        case create_invoice(request) do
            {:error, term} -> {:error, term}
            {:ok, invoice} -> 
                case Stripe.InvoiceItemService.create_invoice_item(invoice, pricing.due_amount) do
                    {:error, term}  -> {:error, term}
                    {:ok, _}     -> 
                        finalize_invoice(invoice)
                        pay_invoice(invoice)
                end
        end
    end

    defp build_description(listing, pricing) do
        text = "We appreciate your business. Thank you for staying with us at " <> listing.name <> "." <>
            "\n" <> 
            "\nRental Fee: " <> pricing.sub_total <> 
            "\nCleaning Fee: " <> pricing.cleaning_fee <> 
            "\nTaxes: " <> pricing.taxes <> 
            "\nTotal: " <> pricing.total  
            "\n" <> 
            "\nFirst invoice due at booking (50%): " <> pricing.due_now <> 
            "\nSecond invoice due in the future: " <> pricing.due_later <> 
            "\n" <> 
            "\nAll deposits are 100% refundable up to 60 days prior to check in. If cancellation occurs with less " <> 
            "than 60 days, we will return any nights rent we are able to rent from another party."

        text
    end



    defp create_invoice(invoice_request) do
        url = "https://api.stripe.com/v1/invoices"

        headers = [] 
        |> Keyword.put(:"Content-Type", "application/x-www-form-urlencoded")
        |> Keyword.put(:"Authorization", "Bearer " <> SettingsService.get_stripe_secret_key())

        body = URI.encode_query(%{
            "customer" => invoice_request.customer_id,
            "colleciton_method" => invoice_request.collection_method,
            "description" => invoice_request.description,
            "due_date" => invoice_request.due_date})
        
        HTTPoison.post(url, body, headers)
        |> handle_response() 
    end

    defp finalize_invoice(invoice) do
        url = "https://api.stripe.com/v1/invoices/" <> invoice.id <> "/finalize"

        headers = [] 
        |> Keyword.put(:"Content-Type", "application/x-www-form-urlencoded")
        |> Keyword.put(:"Authorization", "Bearer " <> SettingsService.get_stripe_secret_key())
        
        HTTPoison.post(url, headers)
        |> handle_response() 
    end

    defp pay_invoice(invoice) do
        url = "https://api.stripe.com/v1/invoices/" <> invoice.id <> "/pay"

        headers = [] 
        |> Keyword.put(:"Content-Type", "application/x-www-form-urlencoded")
        |> Keyword.put(:"Authorization", "Bearer " <> SettingsService.get_stripe_secret_key())
       
        body = URI.encode_query(%{"paid_out_of_band" => true}) 

        HTTPoison.post(url, body, headers)
        |> handle_response() 
    end



    defp handle_response({:ok, %{status_code: 200, body: json}}) do
        response = Poison.decode!(json)

        invoice = %Stripe.Invoice{
            id: response["id"],
            amount_due: response["amount_due"],
            amount_paid: response["amount_paid"],
            amount_remaining: response["amount_remaining"],
            auto_advance: response["auto_advance"],
            charge: response["charge"],
            collection_method: response["collection_method"],
            currency: response["currency"],
            customer_id: response["customer"],
            description: response["description"],
            due_date: response["due_date"],
            paid: response["paid"],
            status: response["status"],
            subtotal: response["subtotal"],
            tax: response["tax"],
            total: response["total"],
        }

        {:ok, invoice}
    end

    defp handle_response({:ok, %{body: json}}) do
        {:error, json}
    end
end