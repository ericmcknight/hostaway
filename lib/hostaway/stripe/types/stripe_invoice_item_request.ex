defmodule Stripe.InvoiceItemRequest do

    @derive Jason.Encoder
    
    defstruct [
        id: "",
        amount: 0,
        currency: "",
        customer_id: "",
        description: "",
        invoice_id: "",
    ]
end