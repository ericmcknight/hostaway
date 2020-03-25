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
        assert half == value.due_now - value.refundable_damage_deposit
        assert half == value.due_later
    end


    test "Start date is now" do
        startDate = Timex.local()
        endDate = Timex.shift(startDate, days: 1)

        {success, _} = HostawayService.get_price(@listing_id, format_date(startDate), format_date(endDate))
        assert :error == success
    end


    test "End date must be greater than start date" do
        startDate = Timex.shift(Timex.now, years: 2)
        endDate = Timex.shift(startDate, days: -2)

        {success, _} = HostawayService.get_price(@listing_id, format_date(startDate), format_date(endDate))
        assert :error == success
    end


    test "Less than minimum number of nights" do
        {_, listing} = ListingsService.get_listing(@listing_id)

        startDate = Timex.shift(Timex.now, years: 2)
        endDate = Timex.shift(startDate, days: listing.minimum_nights - 2)

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


    test "Less than 15 days from now" do
        date = Timex.format!(Timex.shift(Timex.now, days: 2), "{YYYY}-{0M}-{0D}")
        total = 100

        bool = PricingService.is_less_than_15_days_from_now(date)
        assert true == bool

        result = PricingService.due_now(date, total, 0)
        assert 100 == result
    end

    test "More than 15 days from now" do
        date = Timex.format!(Timex.shift(Timex.now, days: 18), "{YYYY}-{0M}-{0D}")
        total = 100

        bool = PricingService.is_less_than_15_days_from_now(date)
        assert false == bool

        result = PricingService.due_now(date, total, 0)
        assert 50 == result
    end


    defp format_date(dt) do
        {_, str} = Timex.format(dt, "{YYYY}-{0M}-{0D}")
        str
    end
end