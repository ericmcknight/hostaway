defmodule Pricing do

    @derive Jason.Encoder

    defstruct [
        :sub_total,
        :cleaning_fee,
        :taxes,
        :refundable_damage_deposit,
        :total,
        :number_of_nights,
        :stripe_secret_key,
        :stripe_publishable_key,
    ]
end