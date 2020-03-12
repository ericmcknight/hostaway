defmodule HostawayWeb.InvoiceControllerTest do
    use ExUnit.Case
    require Timex
    require Logger

    # test "Create invoice in Stripe with an existing Hostaway Reservation" do
    #     listing_id = "70194"
    #     start = Timex.shift(Timex.now, months: 14)

    #     start_date = format_date(start) 
    #     end_date = format_date(Timex.shift(start, days: 4))

    #     {price_status, price} = HostawayService.get_price(listing_id, start_date, end_date)
    #     if price_status == :error do
    #         Logger.debug(price)
    #     end

    #     assert :ok == price_status

    #     price_params = %{
    #         "sub_total" => price.sub_total,
    #         "cleaning_fee" => price.cleaning_fee,
    #         "taxes" => price.taxes,
    #         "refundable_damage_deposit" => price.refundable_damage_deposit,
    #         "total" => price.total,
    #         "due_now" => price.due_now,
    #         "due_later" => price.due_later,
    #         "number_of_nights" => price.number_of_nights,
    #         "stripe_secret_key" => price.stripe_secret_key,
    #         "stipe_publishable_key" => price.stripe_publishable_key
    #     }

    #     {status, value} = HostawayService.pay_reservation("5607752", price_params)
    #     assert :ok == status
    # end


    # test "Create pricing, reservation and invoice in Stripe" do
    #     listing_id = "70704"
    #     start = Timex.shift(Timex.now, months: 16)

    #     start_date = format_date(start) 
    #     end_date = format_date(Timex.shift(start, days: 5))

    #     {price_status, price} = HostawayService.get_price(listing_id, start_date, end_date)
    #     if price_status == :error do
    #         Logger.debug(price)
    #     end

    #     assert :ok == price_status
        
    #     reservation_params = %{
    #         "first_name" => "Eric",
    #         "last_name" => "McKnight",
    #         "email" => "eric@gmail.com",
    #         "phone" => "678 245 7887",
    #         "listing_id" => listing_id,
    #         "arrival_date" => start_date,
    #         "departure_date" => end_date,
    #         "number_of_adults" => 2,
    #         "number_of_children" => 2,
    #         "total" => price.total,
    #         "taxes" => price.taxes,
    #         "cleaning_fee" => price.cleaning_fee,
    #     }

    #     {reserve_status, reservation} = HostawayService.create_reservation(reservation_params)
    #     assert :ok == price_status

    #     price_params = %{
    #         "sub_total" => price.sub_total,
    #         "cleaning_fee" => price.cleaning_fee,
    #         "taxes" => price.taxes,
    #         "refundable_damage_deposit" => price.refundable_damage_deposit,
    #         "total" => price.total,
    #         "due_now" => price.due_now,
    #         "due_later" => price.due_later,
    #         "number_of_nights" => price.number_of_nights,
    #         "stripe_secret_key" => price.stripe_secret_key,
    #         "stipe_publishable_key" => price.stripe_publishable_key
    #     }

    #     {status, value} = HostawayService.pay_reservation(Integer.to_string(reservation.id), price_params)
    #     assert :ok == status
    # end


    defp format_date(dt) do
        {_, str} = Timex.format(dt, "{YYYY}-{0M}-{0D}")
        str
    end
end
   