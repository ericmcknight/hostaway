defmodule Stripe.CustomerService do
    use HTTPoison.Base
    require Logger


    def create_customer(name, email, phone) do
        url = SettingsService.get_stripe_url() <> "/customers"

        headers = [] 
        |> Keyword.put(:"Content-Type", "application/x-www-form-urlencoded")
        |> Keyword.put(:"Authorization", "Bearer " <> SettingsService.get_stripe_secret_key())

       body = URI.encode_query(%{
            "name" => name,
            "email" => email,
            "phone" => phone})
        
        HTTPoison.post(url, body, headers)
        |> handle_create_response()
    end

    defp handle_create_response({:ok, %{status_code: 200, body: json}}) do
        response = Poison.decode!(json)
        # Logger.debug(json)

        customer = %Stripe.Customer{
            id: response["id"],
            name: response["name"],
            email: response["email"],
            phone: response["phone"]
        }

        {:ok, customer}
    end

    defp handle_create_response({:ok, %{body: json}}) do
        {:error, json}
    end



    def delete_customer(customer_id) do
        url = SettingsService.get_stripe_url() <> "/customers/" <> customer_id

        headers = [] 
        |> Keyword.put(:"Content-Type", "application/x-www-form-urlencoded")
        |> Keyword.put(:"Authorization", "Bearer " <> SettingsService.get_stripe_secret_key())

        HTTPoison.delete(url, headers)
        |> handle_delete_response()
    end

    defp handle_delete_response({:ok, %{status_code: 200, body: json}}) do
        response = Poison.decode!(json)
        # Logger.debug(json)

        deleted = %Stripe.CustomerDeleted{
            id: response["id"],
        }

        {:ok, deleted}
    end

    defp handle_delete_response({:ok, %{body: json}}) do
        {:error, json}
    end
end