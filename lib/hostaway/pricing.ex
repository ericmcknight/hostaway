defmodule  JSONAPI.Pricing do
    use HTTPoison.Base
    use Timex
    require Logger

    def price(listing_id, start_date, end_date) do
        case get_listing(listing_id) do
            {:error, reason} -> {:error, reason}
            {:ok, listings} -> 
                List.first(listings)
                |> get_calendars(start_date, end_date)
                |> calculate
       end
    end

    defp get_listing(listing_id) do
        JSONAPI.Listings.listings(listing_id)
    end

    defp get_calendars(listing, start_date, end_date) do
        case JSONAPI.Calendar.calendar(listing["id"], start_date, end_date) do
            {:error, reason} -> {:error, reason}
            {:ok, calendars} -> 
                cond do 
                    Enum.empty?(calendars) -> {:error, "No calendar data was found for the date range"}
                    Enum.any?(calendars, fn day -> false == day["is_available"] end) -> {:error, "At least one of the dates in the date range is not available"}
                    true -> {:ok, %{"listing" => listing, "calendars" => calendars}}
                end
        end
    end

    defp calculate(param) do
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

                case JSONAPI.Stripe.get_client_secret_key(total) do
                    {:error, reason} -> {:error, reason}
                    {:ok, secret} -> 
                        secret_key = secret["client_secret"]
                        Logger.debug(secret_key)

                        {:ok, %{
                            "sub_total" => subtotal, 
                            "cleaning_fee" => cleaning_fee,
                            "taxes" => taxes,
                            "refundable_damage_deposit" => deposit,
                            "total" => total,
                            "number_of_nights" => number_of_nights,
                            "stripe_secret_key" => secret_key
                        }}
 
                end
       end
    end
end