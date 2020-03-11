defmodule Stripe.PaymentIntent do

    @derive Jason.Encoder
    
    defstruct [
        :client_secret_key
    ]
end