defmodule PricingService do
    use HTTPoison.Base
    use Timex
    require Logger


    def get_price(listing_id, start_date, end_date) do
        case get_listing(listing_id) do
            {:error, reason} -> {:error, reason}
            {:ok, listings} -> 
                List.first(listings)
                |> get_calendars(start_date, end_date)
                |> calculate(start_date)
       end
    end


    defp get_listing(listing_id) do
        ListingsService.get_listing(listing_id)
    end

    defp get_calendars(listing, start_date, end_date) do
        case CalendarService.get_calendars(listing["id"], start_date, end_date) do
            {:error, reason} -> {:error, reason}
            {:ok, calendars} -> 
                cond do 
                    Enum.empty?(calendars) -> {:error, "No calendar data was found for the date range."}
                    Enum.any?(calendars, fn day -> false == day["is_available"] end) -> {:error, "At least one of the dates in the date range is not available."}
                    Enum.count(calendars) - 1 < Enum.at(calendars, 0)["minimum_stay"] -> {:error, "This property requires at least " <> Integer.to_string(Enum.at(calendars, 0)["minimum_stay"]) <> " nights per stay."}
                    true -> {:ok, %{"listing" => listing, "calendars" => calendars}}
                end
        end
    end

    defp calculate(param, start_date) do
        # Logger.debug(param)
        case param do
            {:error, msg} -> {:error, msg}
            {:ok, values} -> 
                listing = values["listing"]
                
                calendars = values["calendars"] |> Enum.reverse() |> tl() |> Enum.reverse()
                number_of_nights = Enum.count(calendars)

                tax_rate = listing["tax_rate"]
                cleaning_fee = listing["cleaning_fee"]

                subtotal = Enum.reduce(calendars, 0, fn day, acc -> day["price"] + acc end)
                taxes = Float.round((subtotal + cleaning_fee) * (tax_rate / 100), 2)
                deposit = listing["refundable_damage_deposit"]
                total = subtotal + cleaning_fee + taxes + deposit
                
                due_now = due_now(start_date, total - deposit)
                second_invoice = due_second_invoice(start_date, total - deposit)

                case StripeService.create_payment_intent(due_now) do
                    {:error, reason} -> {:error, reason}
                    {:ok, secret} -> 
                        Logger.debug(secret.client_secret_key)

                        pricing = %Pricing{
                            sub_total: subtotal,
                            cleaning_fee: cleaning_fee,
                            taxes: taxes,
                            refundable_damage_deposit: deposit,
                            total: total,
                            due_now: due_now,
                            due_later: second_invoice,
                            number_of_nights: number_of_nights,
                            stripe_secret_key: secret.client_secret_key,
                            stripe_publishable_key: SettingsService.get_stripe_publishable_key()
                        }

                        {:ok, pricing}
                end
       end
    end


    def due_now(date, total_minus_deposit) do
        case is_less_than_10_days_from_now(date) do
            true    -> total_minus_deposit
            false   -> Float.round(total_minus_deposit / 2, 2)
        end
    end

    def due_second_invoice(date, total_minus_deposit) do
        case is_less_than_10_days_from_now(date) do
            true    -> 0
            false   -> Float.round(total_minus_deposit / 2, 2)
        end
    end

    def is_less_than_10_days_from_now(date) do
        {status, value} = Timex.parse(date, "{YYYY}-{0M}-{0D}") 
        if :error == status do
            {:error, "Date cannot be parsed"}
        else 
            minimum = Timex.shift(Timex.now, days: 10)
            case Timex.compare(value, minimum, :day) do
                1   -> false 
                0   -> true 
                -1  -> true 
            end
        end
    end
end