defmodule Stripe.InvoiceService do
    use HTTPoison.Base
    require Logger
    require Money


    def create_initial_invoice(reservation, listing, pricing) do
        {st, item} = Stripe.InvoiceItemService.create_invoice_item(reservation.stripe_customer_id, pricing.due_now)
        if :error == st do
            {st, item}
        end

        request = %Stripe.InvoiceRequest{
            customer_id: reservation.stripe_customer_id,
            collection_method: "send_invoice",
            description: build_initial_invoice_description(listing, pricing),
            due_date: Timex.shift(Timex.now, days: 1),
        }

        case create_invoice(request) do
            {:error, term} -> 
                {_d, _term} = Stripe.InvoiceItemService.delete_invoice_item(item.id)
                {:error, term}

            {:ok, invoice} -> 
                {_f, _term} = finalize_invoice(invoice)
                {_p, _term} = pay_invoice(invoice)
                {:ok, invoice}
        end
    end

    defp build_initial_invoice_description(listing, pricing) do
        text = "We appreciate your business. Thank you for staying with us at " <> listing.name <> "." <>
            "\n" <> 
            "\nRental Fee: " <> to_currency(pricing.sub_total) <> 
            "\nCleaning Fee: " <> to_currency(pricing.cleaning_fee) <> 
            "\nTaxes: " <> to_currency(pricing.taxes) <> 
            "\nTotal: " <> to_currency(pricing.total) <>
            "\n" <> 
            "\nFirst invoice due at booking (50%): " <> to_currency(pricing.due_now) <> 
            "\nSecond invoice due in the future: " <> to_currency(pricing.due_later) <> 
            "\n" <> 
            "\nAll deposits are 100% refundable up to 60 days prior to check in. If cancellation occurs with less " <> 
            "than 60 days, we will return any nights rent we are able to rent from another party."

        text
    end


    def create_second_invoice(reservation, listing, pricing) do
        {st, item} = Stripe.InvoiceItemService.create_invoice_item(reservation.stripe_customer_id, pricing.due_later)
        if :error == st do
            {st, item}
        end

        {st, date_time} = Timex.parse(reservation.arrival_date, "{YYYY}-{0M}-{0D}")
        if :error == st do
            {:error, date_time}
        end

        request = %Stripe.InvoiceRequest{
            customer_id: reservation.stripe_customer_id,
            collection_method: "send_invoice",
            description: build_second_invoice_description(listing, pricing),
            due_date: Timex.shift(date_time, days: -15),
        }

        case create_invoice(request) do
            {:ok, invoice} -> {:ok, invoice}
            {:error, term} -> 
                {_d, _term} = Stripe.InvoiceItemService.delete_invoice_item(item.id)
                {:error, term}
        end
    end

    def parse_date_text(text) do
        Timex.parse(text, "{YYYY}-{0M}-{0D}") 
    end

    defp build_second_invoice_description(listing, pricing) do
        text = "We appreciate your business. Thank you for staying with us at " <> listing.name <> "." <>
            "\n" <> 
            "\nRental Fee: " <> to_currency(pricing.sub_total) <> 
            "\nCleaning Fee: " <> to_currency(pricing.cleaning_fee) <> 
            "\nTaxes: " <> to_currency(pricing.taxes) <> 
            "\nTotal: " <> to_currency(pricing.total) <>
            "\n" <> 
            "\nSecond invoice due in the future: " <> to_currency(pricing.due_later) <> 
            "\n" <> 
            "\nAll deposits are 100% refundable up to 60 days prior to check in. If cancellation occurs with less " <> 
            "than 60 days, we will return any nights rent we are able to rent from another party."

        text
    end

    def to_currency(amount) do
        Money.to_string(Money.new(Kernel.trunc(amount * 100), :USD), symbol: true)
    end


    defp create_invoice(invoice_request) do
        url = SettingsService.get_stripe_url() <> "/invoices"

        headers = [] 
        |> Keyword.put(:"Content-Type", "application/x-www-form-urlencoded")
        |> Keyword.put(:"Authorization", "Bearer " <> SettingsService.get_stripe_secret_key())

        body = URI.encode_query(%{
            "customer" => invoice_request.customer_id,
            "collection_method" => invoice_request.collection_method,
            "description" => invoice_request.description,
            "auto_advance" => false,
            "due_date" => Timex.to_unix(invoice_request.due_date)})
        
        HTTPoison.post(url, body, headers)
        |> handle_response() 
    end

    defp finalize_invoice(invoice) do
        url = SettingsService.get_stripe_url() <> "/invoices/" <> invoice.id <> "/finalize"

        headers = [] 
        |> Keyword.put(:"Content-Type", "application/x-www-form-urlencoded")
        |> Keyword.put(:"Authorization", "Bearer " <> SettingsService.get_stripe_secret_key())
        
        body = URI.encode_query(%{}) 

        HTTPoison.post(url, body, headers)
        |> handle_response() 
    end

    defp pay_invoice(invoice) do
        url = SettingsService.get_stripe_url() <> "/invoices/" <> invoice.id <> "/pay"

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