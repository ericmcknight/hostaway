defmodule Pricing do

    @derive Jason.Encoder

    defstruct [
        sub_total: 0,
        cleaning_fee: 0,
        taxes: 0,
        refundable_damage_deposit: 0,
        total: 0,
        due_now: 0,
        due_later: 0,
        number_of_nights: 0,
        stripe_secret_key: "",
        stripe_publishable_key: "",
    ]
end