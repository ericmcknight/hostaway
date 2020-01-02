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
        if nil == listing do 
            {:error, "No listing was found"}
        end 

        case JSONAPI.Calendar.calendar(listing["id"], start_date, end_date) do
            {:error, reason} -> {:error, reason}
            {:ok, calendars} -> 
                if Enum.empty?(calendars) do
                    {:error, "No calendar data was found for the date range"}
                end

                if Enum.any?(calendars, fn day -> !day["is_available"] end) do
                    {:error, "At least one of the dates in the date range is not available"}
                end

                {:ok, %{"listing" => listing, "calendars" => calendars}}
        end
    end

    defp calculate(param) do
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

                {:ok, %{
                    "sub_total" => subtotal, 
                    "cleaning_fee" => cleaning_fee,
                    "taxes" => taxes,
                    "refundable_damage_deposit" => deposit,
                    "total" => total,
                    "number_of_nights" => number_of_nights
                }}
        end
    end
end