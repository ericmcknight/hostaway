defmodule Listing do

    @derive Jason.Encoder

    defstruct [
        id: 0,
        name: "",
        description: "",
        street: "",
        address: "",
        city: "",
        state: "",
        zipcode: "",
        lat: 0,
        lng: 0,
        room_type: "",
        max_pets_allowed: 0,
        allow_same_day_booking: 0,
        bathrooms_number: 0,
        bedrooms_number: 0,
        price: 0,
        tax_rate: 0,
        cleaning_fee: 0,
        refundable_damage_deposit: 0,
        minimum_nights: 0,
        person_capacity: 0,
        country_code: "",
        check_in_time: 0,
        check_out_time: 0,
    ]
end