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
        Stripe.InvoiceService.create_invoice_initial_payment(reservation, listing, pricing)
    end
end