defmodule Stripe.Invoice do

    @derive Jason.Encoder
    
    defstruct [
        id: "",
        amount_due: 0,
        amount_paid: 0,
        amount_remaining: 0,
        auto_advance: false,
        charge: "",
        collection_method: "",
        currency: "",
        customer_id: "",
        description: "",
        due_date: nil,
        paid: false,
        status: "",
        subtotal: 0,
        tax: 0,
        total: 0,
    ]
end