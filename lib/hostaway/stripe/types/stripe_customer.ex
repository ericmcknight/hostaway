defmodule Stripe.Customer do

    @derive Jason.Encoder
    
    defstruct [
        id: "",
        name: "",
        email: "",
        phone: "",
    ]
end