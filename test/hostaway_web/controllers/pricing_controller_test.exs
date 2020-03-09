defmodule HostawayWeb.PricingControllerTest do
    use ExUnit.Case
    require Timex
    require Logger


    @listing_id "70194"


    test "Verify the number of nights" do
        startDate = Timex.shift(Timex.now, years: 2)
        endDate = Timex.shift(startDate, days: 4)

        {success, value} = JSONAPI.Pricing.price(@listing_id, format_date(startDate), format_date(endDate))

        assert :ok == success
        assert nil != value
        assert 4 == value["number_of_nights"]
    end


    test "End date must be greater than start date" do
        startDate = Timex.shift(Timex.now, years: 2)
        endDate = Timex.shift(startDate, days: -2)

        {success, _} = JSONAPI.Pricing.price(@listing_id, format_date(startDate), format_date(endDate))
        assert :error == success
    end


    test "Less than minimum number of nights" do
        {_, value} = JSONAPI.Listings.listings(@listing_id)
        listing = List.first(value)

        startDate = Timex.shift(Timex.now, years: 2)
        endDate = Timex.shift(startDate, days: listing["minimum_nights"] - 2)

        {success, value} = JSONAPI.Pricing.price(@listing_id, format_date(startDate), format_date(endDate))
        assert :error == success, value
    end


    test "Before today" do
        startDate = Timex.shift(Timex.now, months: -2)
        endDate = Timex.shift(startDate, days: 4)

        {success, _} = JSONAPI.Pricing.price(@listing_id, format_date(startDate), format_date(endDate))
        assert :error == success
    end


    test "Too far into the future error" do
        startDate = Timex.shift(Timex.now, years: 4)
        endDate = Timex.shift(startDate, days: 4)

        {success, _} = JSONAPI.Pricing.price(@listing_id, format_date(startDate), format_date(endDate))
        assert :error == success
    end


    defp format_date(dt) do
        {_, str} = Timex.format(dt, "{YYYY}-{0M}-{0D}")
        str
    end
end