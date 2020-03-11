defmodule Stripe.InvoiceRequest do

    @derive Jason.Encoder
    
    defstruct [
        customer_id: "",
        collection_method: "",
        description: "",
        due_date: nil,
    ]
end