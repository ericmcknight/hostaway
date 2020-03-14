defmodule StripeService do
    use HTTPoison.Base
    require Logger


    def create_payment_intent(amount) do
        Stripe.PaymentIntentService.create_payment_intent(amount)
    end


    def create_customer(name, email, phone) do
        Stripe.CustomerService.create_customer(name, email, phone)
    end

    def delete_customer(customer_id) do
        Stripe.CustomerService.delete_customer(customer_id)
    end


    def create_invoices(reservation, listing, pricing) do
        case Stripe.InvoiceService.create_initial_invoice(reservation, listing, pricing) do
            {:error, term} -> {:error, term}
            {:ok, _invoice} -> 
                Stripe.InvoiceService.create_second_invoice(reservation, listing, pricing)
        end
    end
end