defmodule Stripe.InvoiceItem do

    @derive Jason.Encoder
    
    defstruct [
        id: "",
        currency: "",
        customer_id: "",
        amount: 0,
        description: "",
        invoice_id: "",
    ]
end
