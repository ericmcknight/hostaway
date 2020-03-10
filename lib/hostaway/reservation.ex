defmodule Reservation do

    @derive Jason.Encoder

    defstruct [
        id: 0, 
        listing_id: 0,
        status: "",
        reservation_id: "",
        channel_id: 0,
        channel_reservation_id: "",
        channel_name: "",
        hostaway_reservation_id: "",
        arrival_date: nil,
        departure_date: nil,
        check_out_time: nil,
        phone: "",
        email: "",
        name: "",
        nights: 0,
        number_of_guests: 0,
        currency: "",
        cleaning_fee: 0,
        tax_amount: 0,
        total: 0,
        is_paid: false,
        stripe_customer_id: "",
    ]

end