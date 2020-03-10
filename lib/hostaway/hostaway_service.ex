defmodule HostawayService do
    use HTTPoison.Base
    require Logger


    def get_listings() do
        ListingsService.get_listings()
    end

    def get_listing(listing_id) do
        ListingsService.get_listing(listing_id)
    end

    def get_calendars(listing_id, start_date, end_date) do
        CalendarService.get_calendars(listing_id, start_date, end_date)
    end

    def get_price(listing_id, start_date, end_date) do
        PricingService.get_price(listing_id, start_date, end_date)
    end


    def get_reservation(reservation_id) do
        ReservationService.get_reservation(reservation_id)
    end

    def pay_reservation(reservation_id) do
        ReservationService.pay(reservation_id)
    end


    def create_reservation(params) do
        name = params["first_name"] <> " " <> params["last_name"]
        email = params["email"]
        phone = params["phone"]

        case Stripe.CustomerService.create_customer(name, email, phone) do
            {:error, term} -> {:error, term}
            {:ok, customer} -> ReservationService.create(params, customer.id)
        end
    end

end