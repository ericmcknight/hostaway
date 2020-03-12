defmodule ReservationService do
    use HTTPoison.Base
    require Logger


    def get_reservation(reservation_id) do
        case AuthenticationService.auth() do
            {:error, json} -> {:error, json}
            {:ok, token} -> get_reservation(reservation_id, token)
       end
    end

    def get_reservation(reservation_id, token) do
        headers = []
        |> Keyword.put(:"Content-Type", "application/json")
        |> Keyword.put(:"Authorization", token["token"])

        get(SettingsService.get_url() <> "reservations/" <> reservation_id, headers)
        |> handle_response()
    end


    def create(params, stripe_customer_id) do
        case AuthenticationService.auth() do
            {:error, json} -> {:error, json}
            {:ok, token} -> create_reservation(params, stripe_customer_id, token)
        end
    end 

    defp create_reservation(params, stripe_customer_id, token) do
        listing_id = params["listing_id"]
        arrival = params["arrival_date"]
        depart = params["departure_date"]
        channel_id = 2000 # direct reservation
        source = "socialSphereApi"
        status = "awaitingPayment"

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
        is_paid = false # params["is_paid"]

        url = SettingsService.get_url() <> "reservations"

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
            "currency" => "USD",
            "status" => status,
            "stripeGuestId" => stripe_customer_id,
        })
        
        HTTPoison.post(url, body, headers)
        |> handle_response()
    end



    def pay(reservation_id) do
        case AuthenticationService.auth() do
            {:error, json} -> {:error, json}
            {:ok, token} -> pay(reservation_id, token)
        end
    end

    def pay(reservation_id, token) do
        pay_for_reservation(reservation_id, token)
    end

    defp pay_for_reservation(reservation_id, token) do
        url = SettingsService.get_url() <> "reservations/" <> reservation_id

        headers = [] 
        |> Keyword.put(:"Content-Type", "application/json")
        |> Keyword.put(:"Authorization", token["token"])

        body = Poison.encode!(%{
            "isPaid" => true,
            "status" => "new"
        })
        
        HTTPoison.put(url, body, headers)
        |> handle_response()
    end



    defp handle_response({:ok, %{status_code: 200, body: json}}) do
        response = Poison.decode!(json)
        # Logger.debug(json)

        prop = response["result"]
        reservation = %Reservation{
            id: prop["id"],
            listing_id: prop["listingMapId"],
            status: prop["status"],
            reservation_id: prop["reservationId"],
            channel_id: prop["channelId"],
            channel_reservation_id: prop["channelReservationId"],
            channel_name: prop["channelName"],
            hostaway_reservation_id: prop["hostawayReservationId"],
            arrival_date: prop["arrivalDate"],
            departure_date: prop["departureDate"],
            check_out_time: prop["checkOutTime"],
            phone: prop["phone"],
            email: prop["guestEmail"],
            name: prop["guestName"],
            nights: prop["nights"],
            number_of_guests: prop["numberOfGuests"],
            currency: prop["currency"],
            cleaning_fee: prop["cleaningFee"],
            tax_amount: prop["taxAmount"],
            total: prop["totalPrice"],
            is_paid: prop["isPaid"] == 1, 
            stripe_customer_id: prop["stripeGuestId"]
        }

        {:ok, reservation}
    end
   
    defp handle_response({:ok, %{body: json}}) do
        {:error, json}
    end

    defp handle_response({:error, reason}) do
        msg = "Http error from hostaway.com. " <> reason
        {:error, msg}
    end 

end