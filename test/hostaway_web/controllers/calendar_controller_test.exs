defmodule HostawayWeb.CalendarControllerTest do
    use ExUnit.Case
    require Timex
    require Logger
   
    @listing_id "70194"


    test "Get calendar" do
        startDate = Timex.shift(Timex.now, months: 2)
        endDate = Timex.shift(startDate, days: 4)

        {success, _value} = HostawayService.get_calendars(@listing_id, format_date(startDate), format_date(endDate))
        # Logger.debug(Enum.at(value,0)["date"])
        assert :ok == success
    end

    test "Get calendar - failure because start date is before today" do
        startDate = Timex.shift(Timex.now, days: -2)
        endDate = Timex.shift(startDate, days: 4)

        {success, _} = HostawayService.get_calendars(@listing_id, format_date(startDate), format_date(endDate))
        assert :error == success
    end



    test "Get calendar - parsing valid date" do
        {result, _} = CalendarService.parse_date_text(format_date(Timex.local())) 
        assert :ok == result
    end



    test "Date is less than today" do
        result = CalendarService.is_less_than_today(Timex.shift(Timex.local(), days: -1))
        assert true == result
    end

    test "Date is today" do
        result = CalendarService.is_less_than_today(Timex.local())
        assert false == result
    end

    test "Date is greater than today" do
        result = CalendarService.is_less_than_today(Timex.shift(Timex.now, days: 1))
        assert false == result
    end



    defp format_date(dt) do
        {_, str} = Timex.format(dt, "{YYYY}-{0M}-{0D}")
        str
    end
end