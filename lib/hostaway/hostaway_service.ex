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


    def pay_reservation(reservation_id, params) do
        pricing = %Pricing{
            sub_total: params["subtotal"],
            cleaning_fee: params["cleaning_fee"],
            taxes: params["taxes"],
            refundable_damage_deposit: params["refundable_damage_deposit"],
            total: params["total"],
            due_now: params["due_now"],
            due_later: params["due_later"],
            number_of_nights: params["number_of_nights"],
            stripe_secret_key: params["stripe_secret_key"],
            stripe_publishable_key: params["stripe_publishable_key"]
        }

        case ReservationService.pay(reservation_id) do
            {:error, term} -> {:error, term}
            {:ok, reservation} -> 
                case ListingsService.get_listing(reservation.listing_id) do
                    {:error, term} -> {:error, term}
                    {:ok, listing} -> StripeService.create_invoices(reservation, listing, pricing)
                end
        end
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