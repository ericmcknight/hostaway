defmodule ListingsService do
    use HTTPoison.Base
    require Logger
    
    def get_listings() do
        case AuthenticationService.auth() do
            {:error, json} -> {:error, json}
            {:ok, token} -> 
                headers = []
                |> Keyword.put(:"Content-Type", "application/json")
                |> Keyword.put(:"Authorization", token["token"])

                get(SettingsService.get_url() <> "listings/", headers)
                |> handle_list_response()
       end
    end

    defp handle_list_response({:ok, %{status_code: 200, body: json}}) do
        {:ok, map_listings(Poison.decode!(json)["result"])}
    end

    defp handle_list_response({:ok, %{body: json}}) do
        {:error, json}
    end

    defp map_listings(results) do
        case Enum.empty?(results) do
            true -> %{}
            false -> Enum.map(results, &map_listing/1)
        end
    end



    def get_listing(listing_id) do
        case AuthenticationService.auth() do
            {:error, json} -> {:error, json}
            {:ok, token} -> 
                headers = []
                |> Keyword.put(:"Content-Type", "application/json")
                |> Keyword.put(:"Authorization", token["token"])

                get(SettingsService.get_url() <> "listings/" <> listing_id, headers)
                |> handle_single_response()
       end
    end

    defp handle_single_response({:ok, %{status_code: 200, body: json}}) do
        {:ok, map_listing(Poison.decode!(json)["result"])}
    end

    defp handle_single_response({:ok, %{body: json}}) do
        {:error, json}
    end

    defp map_listing(prop) do
        %Listing{
            id: prop["id"],
            name: prop["name"],
            description: prop["description"],
            street: prop["street"],
            address: prop["address"],
            city: prop["city"],
            state: prop["state"],
            zipcode: prop["zipcode"],
            lat: prop["lat"],
            lng: prop["lng"],
            room_type: prop["roomType"],
            max_pets_allowed: prop["maxPetsAllowed"],
            allow_same_day_booking: prop["allowSameDayBooking"],
            bathrooms_number: prop["bathroomsNumber"],
            bedrooms_number: prop["bedroomsNumber"],
            price: prop["price"],
            tax_rate: prop["propertyRentTax"],
            cleaning_fee: prop["cleaningFee"],
            refundable_damage_deposit: prop["refundableDamageDeposit"],
            minimum_nights: prop["minNights"],
            person_capacity: prop["personCapacity"],
            country_code: prop["countryCode"],
            check_in_time: prop["checkInTime"],
            check_out_time: prop["checkOutTime"]
        } 
    end
end