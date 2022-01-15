defmodule GoodTimes do
  @moduledoc """
  GoodTimes contains some helpful functions for operating on DateTime-like
  maps.
  """

  @minute_in_secs 60
  @hour_in_mins 60
  @day_in_hours 24

  @doc """
  bucket/3 takes a DateTime-like map and buckets it by the time unit supplied,
  starting from the beginning of time (unix epoch). It returns a DateTime.
  This uses common expectations about what an minute, hour, day, etc are in
  seconds. It preserves any calender and time zone information.
  """
  def bucket(dt, 1, :day) do
    beginning_of_day(dt)
  end

  def bucket(
        %{
          year: _,
          month: _,
          day: _,
          calendar: _,
          hour: _,
          minute: _,
          second: _,
          microsecond: _,
          std_offset: _,
          utc_offset: _,
          zone_abbr: _,
          time_zone: _
        } = dt,
        count,
        :day
      ) do
    case unix_wrap(dt, :second, &(&1 - rem(&1, count * @day_in_hours * @hour_in_mins * @minute_in_secs))) do
      {:ok, result} -> result
      _ -> raise ArgumentError, message: "that doesn't seem to be a DateTime or similar"
    end
  end

  def bucket(
        %{
          year: _,
          month: _,
          day: _,
          calendar: _,
          hour: _,
          minute: _,
          second: _,
          microsecond: _,
          std_offset: _,
          utc_offset: _,
          zone_abbr: _,
          time_zone: _
        } = dt,
        count,
        :hour
      ) do
    case unix_wrap(dt, :second, &(&1 - rem(&1, count * @hour_in_mins * @minute_in_secs))) do
      {:ok, result} -> result
      _ -> raise ArgumentError, message: "that doesn't seem to be a DateTime or similar"
    end
  end

  def bucket(
        %{
          year: _,
          month: _,
          day: _,
          calendar: _,
          hour: _,
          minute: _,
          second: _,
          microsecond: _,
          std_offset: _,
          utc_offset: _,
          zone_abbr: _,
          time_zone: _
        } = dt,
        count,
        :minute
      ) do
    case unix_wrap(dt, :second, &(&1 - rem(&1, count * @minute_in_secs))) do
      {:ok, result} -> result
      _ -> raise ArgumentError, message: "that doesn't seem to be a DateTime or similar"
    end
  end

  def bucket(
        %{
          year: _,
          month: _,
          day: _,
          calendar: _,
          hour: _,
          minute: _,
          second: _,
          microsecond: _,
          std_offset: _,
          utc_offset: _,
          zone_abbr: _,
          time_zone: _
        } = dt,
        count,
        :second
      ) do
    result =
      dt
      |> DateTime.to_unix(:microsecond)
      |> (&(&1 - rem(&1, count * 1_000_000))).()
      |> (&(&1 / 1_000_000)).()
      |> trunc()
      |> DateTime.from_unix(:second)

    case result do
      {:ok, val} -> val
      _ -> raise ArgumentError, message: "that doesn't seem to be a DateTime or similar"
    end
  end

  @doc """
  beginning_of_day/1 returns a DateTime struct that carries over the year, month
  and day information from the passed-in DateTime-like map. It preserves time
  zone and calendar information.
  """
  def beginning_of_day(%{
        year: _,
        month: _,
        day: _,
        calendar: _,
        hour: _,
        minute: _,
        second: _,
        microsecond: _,
        std_offset: _,
        utc_offset: _,
        zone_abbr: _,
        time_zone: _
      } = dt) do
      Map.merge(dt, %{hour: 0, minute: 0, second: 0, microsecond: {0, 0}})
  end

  @doc """
  end_of_day/1 takes a DateTime-like map, and returns a DateTime set to the
  last microsecond of the specified day. It converts to unix micros and does
  math on that because DateTime.add(-1, :microsecond) returns precision based
  on input precision, so it always has 1 second precision. But, we always
  want microsecond precision out.
  """
  def end_of_day(
        %{
          year: _,
          month: _,
          day: _,
          calendar: _,
          hour: _,
          minute: _,
          second: _,
          microsecond: _,
          std_offset: _,
          utc_offset: _,
          zone_abbr: _,
          time_zone: _
        } = dt
      ) do
      Map.merge(dt, %{hour: 23, minute: 59, second: 59, microsecond: {999999, 6}})
  end

  @doc """
  beginning_of_week/1 accepts a DateTime-like map and returns a DateTime
  pointing to the start of the week in which that input DateTime falls. It uses
  the original Calendar to do that, so it should work for different calendars.
  """
  def beginning_of_week(
        %{
          year: year,
          month: month,
          day: day,
          calendar: calendar,
          hour: _,
          minute: _,
          second: _,
          microsecond: _,
          std_offset: _,
          utc_offset: _,
          zone_abbr: _,
          time_zone: _
        } = dt
      ) do

    {day_of_week, _, _} = calendar.day_of_week(year, month, day, :default)
    subbed_days = 0 - day_of_week + 1

    dt
    |> beginning_of_day()
    |> add_days(subbed_days)
  end

  @doc """
  end_of_week/1 accepts a DateTime-like map and returns a DateTime pointing to
  the end of the week in which that input DateTime falls. It uses the original
  Calendar to do that, so it should work for different calendars.
  """
  def end_of_week(
        %{
          year: year,
          month: month,
          day: day,
          calendar: calendar,
          hour: _,
          minute: _,
          second: _,
          microsecond: _,
          std_offset: _,
          utc_offset: _,
          zone_abbr: _,
          time_zone: _
        } = dt
      ) do
    {day_of_week, _, _} = calendar.day_of_week(year, month, day, :default)
    added_days = 7 - day_of_week

    dt
    |> end_of_day()
    |> add_days(added_days)
  end

  @doc """
  beginning_of_month/1 accepts a DateTime-like map and returns a DateTime
  pointing to the start of the month in which that input DateTime falls. It
  uses the original Calendar to do that, so it should work for different
  calendars.
  """
  def beginning_of_month(
        %{
          year: _,
          month: _,
          day: _,
          calendar: _,
          hour: _,
          minute: _,
          second: _,
          microsecond: _,
          std_offset: _,
          utc_offset: _,
          zone_abbr: _,
          time_zone: _
        } = dt
      ) do
    dt
    |> Map.put(:day, 1)
    |> beginning_of_day()
  end

  @doc """
  end_of_month/1 accepts a DateTime-like map and returns a DateTime pointing to
  the end of the month in which that input DateTime falls. It uses the original
  Calendar to do that, so it should work for different calendars.
  """
  def end_of_month(
        %{
          year: year,
          month: month,
          day: _,
          calendar: calendar,
          hour: _,
          minute: _,
          second: _,
          microsecond: _,
          std_offset: _,
          utc_offset: _,
          zone_abbr: _,
          time_zone: _
        } = dt
      ) do

    days_in_month = calendar.days_in_month(year, month)

    dt
    |> Map.put(:day, days_in_month)
    |> end_of_day()
  end

  @doc """
  beginning_of_year/1 accepts a DateTime-like map and returns a DateTime pointing to
  the start of the year in which that input DateTime falls. It uses the original
  Calendar to do that, so it should work for different calendars.
  """
  def beginning_of_year(
        %{
          year: _,
          month: _,
          day: _,
          calendar: _,
          hour: _,
          minute: _,
          second: _,
          microsecond: _,
          std_offset: _,
          utc_offset: _,
          zone_abbr: _,
          time_zone: _
        } = dt
      ) do

    dt
    |> Map.merge(%{month: 1, day: 1})
    |> beginning_of_day()
  end

  @doc """
  end_of_year/1 accepts a DateTime-like map and returns a DateTime pointing to
  the end of the year in which that input DateTime falls. It uses the original
  Calendar to do that, so it should work for different calendars.
  """
  def end_of_year(
        %{
          year: _,
          month: _,
          day: _,
          calendar: _,
          hour: _,
          minute: _,
          second: _,
          microsecond: _,
          std_offset: _,
          utc_offset: _,
          zone_abbr: _,
          time_zone: _
        } = dt
      ) do

    dt
    |> Map.merge(%{month: 12, day: 31})
    |> end_of_day()
  end

  defp add_days(dt, count) do
    DateTime.add(dt, count * @day_in_hours * @hour_in_mins * @minute_in_secs * 1_000_000, :microsecond)
  end

  # Wrapper to make it less painful to run a function on the unix epoch seconds
  # for a DateTime.
  defp unix_wrap(dt, unit, func) do
    dt
    |> DateTime.to_unix(unit)
    |> func.()
    |> DateTime.from_unix(unit)
  end
end
