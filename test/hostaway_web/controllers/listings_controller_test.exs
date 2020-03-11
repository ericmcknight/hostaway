defmodule HostawayWeb.ListingsControllerTest do
    use ExUnit.Case
    require Logger
   
    test "Get all listings" do
        {success, value} = HostawayService.get_listings()

        assert :ok == success
        assert nil != List.first(value)
    end
    
    test "Get single listing value" do
        {success, value} = HostawayService.get_listing("70194")

        assert :ok == success
        assert nil != value
        assert 70194 == value.id
    end

end