defmodule JSONAPI.BookingService do
    use HTTPoison.Base
    require Logger

    def new_booking(params) do
        case JSONAPI.Authentication.auth() do
            {:error, json} -> {:error, json}
            {:ok, token} -> create_booking(params, token)
        end
    end 

    def pay(params) do
        case JSONAPI.Authentication.auth() do
            {:error, json} -> {:error, json}
            {:ok, token} -> create_booking(params, token)
        end
    end


    defp pay_booking(params, token) do
        url = JSONAPI.Settings.get_url() <> "reservations/" <> params["reservation_id"]

        headers = [] 
        |> Keyword.put(:"Content-Type", "application/json")
        |> Keyword.put(:"Authorization", token["token"])

        body = Poison.encode!(%{
            "isPaid" => true 
        })
        
        HTTPoison.post(url, body, headers)
        |> handle_response()
    end


    defp create_booking(params, token) do
        listing_id = params["listing_id"]
        arrival = params["arrival_date"]
        depart = params["departure_date"]
        channel_id = 2000 # direct reservation
        source = "socialSphereApi"

        first_name = params["first_name"]
        last_name = params["last_name"]
        full_name = first_name <> " " <> last_name

        adults = params["number_of_adults"]
        children = params["number_of_children"]
        total_guests = adults + children
        email = params["email"]
        phone = params["phone"]

        total = params["total"]
        taxes = params["taxes"]
        cleaning_fee = params["cleaning_fee"]
        # security_deposit = params["damage_deposit"]
        is_paid = params["is_paid"]

        url = JSONAPI.Settings.get_url() <> "reservations"

        headers = [] 
        |> Keyword.put(:"Content-Type", "application/json")
        |> Keyword.put(:"Authorization", token["token"])

        body = Poison.encode!(%{
            "channelId" => channel_id, 
            "listingMapId" => listing_id,
            "isManuallyChecked" => 0,
            "guestName" => full_name,
            "guestFirstName" => first_name,
            "guestLastName" => last_name,
            "guestEmail" => email,
            "numberOfGuests" => total_guests,
            "adults" => adults,
            "children" => children,
            "arrivalDate" => arrival,
            "departureDate" => depart,
            "phone" => phone,
            "totalPrice" => total,
            "taxAmount" => taxes,
            "cleaningFee" => cleaning_fee,
            "isPaid" => is_paid,
            "currency" => "USD"
        })
        
        HTTPoison.post(url, body, headers)
        |> handle_response()
    end
    
    defp handle_response({:ok, %{status_code: 200, body: json}}) do
        {:ok, [map_reservation(Poison.decode!(json)["result"])]}
    end

    defp handle_response({:ok, %{body: json}}) do
        {:error, json}
    end

    defp handle_response({:error, reason}) do
        msg = "Http error from hostaway.com. " <> reason
        {:error, msg}
    end


    defp map_reservation(prop) do
        %{
            "id" => prop["id"],
            "listing_id" => prop["listingMapId"],
            "status" => prop["status"],
            "reservation_id" => prop["reservationId"],
            "channel_id" => prop["channelId"],
            "channel_reservation_id" => prop["channelReservationId"],
            "channel_name" => prop["channelName"],
            "hostaway_reservation_id" => prop["hostawayReservationId"],
            "phone" => prop["phone"],
            "email" => prop["guestEmail"],
            "name" => prop["guestName"],
            "nights" => prop["nights"],
            "number_of_guests" => prop["numberOfGuests"],
            "currency" => prop["currency"],
            "cleaning_fee" => prop["cleaningFee"],
            "check_out_time" => prop["checkOutTime"],
            "total" => prop["totalPrice"],
        } 
    end
end