defmodule HostawayWeb.PricingControllerTest do
    use ExUnit.Case
    require Timex
    require Logger


    @listing_id "70194"


    test "Verify the number of nights" do
        startDate = Timex.shift(Timex.now, years: 2)
        endDate = Timex.shift(startDate, days: 4)

        {success, value} = HostawayService.get_price(@listing_id, format_date(startDate), format_date(endDate))

        assert :ok == success
        assert nil != value
        assert 4 == value.number_of_nights

        half = Float.round((value.total - value.refundable_damage_deposit) / 2, 2)
        assert half == value.due_now
        assert half == value.due_later
    end


    test "End date must be greater than start date" do
        startDate = Timex.shift(Timex.now, years: 2)
        endDate = Timex.shift(startDate, days: -2)

        {success, _} = HostawayService.get_price(@listing_id, format_date(startDate), format_date(endDate))
        assert :error == success
    end


    test "Less than minimum number of nights" do
        {_, value} = ListingsService.get_listing(@listing_id)
        listing = List.first(value)

        startDate = Timex.shift(Timex.now, years: 2)
        endDate = Timex.shift(startDate, days: listing["minimum_nights"] - 2)

        {success, value} = HostawayService.get_price(@listing_id, format_date(startDate), format_date(endDate))
        assert :error == success, value
    end


    test "Before today" do
        startDate = Timex.shift(Timex.now, months: -2)
        endDate = Timex.shift(startDate, days: 4)

        {success, _} = HostawayService.get_price(@listing_id, format_date(startDate), format_date(endDate))
        assert :error == success
    end


    test "Too far into the future error" do
        startDate = Timex.shift(Timex.now, years: 4)
        endDate = Timex.shift(startDate, days: 4)

        {success, _} = HostawayService.get_price(@listing_id, format_date(startDate), format_date(endDate))
        assert :error == success
    end


    test "Less than 10 days from now" do
        date = Timex.format!(Timex.shift(Timex.now, days: 2), "{YYYY}-{0M}-{D}")
        total = 100

        bool = PricingService.is_less_than_10_days_from_now(date)
        assert true == bool

        result = PricingService.due_now(date, total)
        assert 100 == result
    end

    test "More than 10 days from now" do
        date = Timex.format!(Timex.shift(Timex.now, days: 12), "{YYYY}-{0M}-{D}")
        total = 100

        bool = PricingService.is_less_than_10_days_from_now(date)
        assert false == bool

        result = PricingService.due_now(date, total)
        assert 50 == result
    end


    defp format_date(dt) do
        {_, str} = Timex.format(dt, "{YYYY}-{0M}-{0D}")
        str
    end
end