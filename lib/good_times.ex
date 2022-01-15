defmodule GoodTimes do
  @moduledoc """
  GoodTimes contains some helpful functions for operating on DateTime-like
  maps.
  """

  @minute_in_secs 60
  @hour_in_mins 60
  @day_in_hours 24

  @doc """
  Takes a DateTime-like map and buckets it by the time unit supplied, starting
  from the beginning of time (unix epoch). It returns a DateTime.  This uses
  common expectations about what an minute, hour, day, etc are in seconds. It
  preserves any calender and time zone information.

  Note that the bucketing algorithm is hard buckets since the beginning of the
  epoch. That is desirable because it means you will always have stable bucket
  sizes.

  However, it might produce somewhat different results that you expect. For
  example, 7 minute buckets begin from the start of the epoch, not from the
  start of the day. This means the first 7 minute bucket of any particular day
  might be the 3rd minute of the day. The same principle applies to the other
  bucket sizes. Any bucket size by which a day can be evenly divided will,
  however, always line up with the day.

  Valid bucket sizes are one of:

    `:day`, `:hour`, `:minute`, `:second`

  ## Examples

      iex> GoodTimes.bucket(~U[2021-01-13 14:07:06.098765Z], 1, :day)
      ~U[2021-01-13 00:00:00Z]

      iex> GoodTimes.bucket(~U[2021-02-17 14:53:06.098765Z], 23, :day)
      ~U[2021-01-26 00:00:00Z]

      iex> GoodTimes.bucket(~U[2021-01-13 14:07:06.098765Z], 1, :hour)
      ~U[2021-01-13 14:00:00Z]

  """
  # Optimized implementation for a single day
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
      other -> other
    end
  end

  # Optimized implementation for a single hour
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
        1,
        :hour
      ) do
    Map.merge(dt, %{minute: 0, second: 0, microsecond: {0, 0}})
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
      other -> other
    end
  end

  # Optimized implementation for a single minute
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
        1,
        :minute
      ) do
    Map.merge(dt, %{second: 0, microsecond: {0, 0}})
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
      other -> other
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
      other -> other
    end
  end

  @doc """
  Returns a DateTime struct that carries over the year, month and day
  information from the passed-in DateTime-like map. It preserves time zone and
  calendar information.

  ## Examples

      iex> GoodTimes.beginning_of_day(~U[2022-01-13 14:07:06.098765Z])
      ~U[2022-01-13 00:00:00Z]
  """
  def beginning_of_day(
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
    Map.merge(dt, %{hour: 0, minute: 0, second: 0, microsecond: {0, 0}})
  end

  @doc """
  Takes a DateTime-like map, and returns a DateTime set to the last microsecond
  of the specified day. It converts to unix micros and does math on that
  because DateTime.add(-1, :microsecond) returns precision based on input
  precision, so it always has 1 second precision. But, we always want
  microsecond precision out.

  ## Examples

      iex> GoodTimes.end_of_day(~U[2022-01-13 14:07:06.098765Z])
      ~U[2022-01-13 23:59:59.999999Z]
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
    Map.merge(dt, %{hour: 23, minute: 59, second: 59, microsecond: {999_999, 6}})
  end

  @doc """
  Accepts a DateTime-like map and returns a DateTime pointing to the start of
  the week in which that input DateTime falls. It uses the original Calendar to
  do that, so it should work for different calendars.

  ## Examples

      iex> GoodTimes.beginning_of_week(~U[2022-01-13 14:07:06.098765Z])
      ~U[2022-01-10 00:00:00Z]
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
  Accepts a DateTime-like map and returns a DateTime pointing to the end of the
  week in which that input DateTime falls. It uses the original Calendar to do
  that, so it should work for different calendars.

  ## Examples

      iex> GoodTimes.end_of_week(~U[2022-01-13 14:07:06.098765Z])
      ~U[2022-01-16 23:59:59.999999Z]
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
  Accepts a DateTime-like map and returns a DateTime pointing to the start of
  the month in which that input DateTime falls. It uses the original Calendar
  to do that, so it should work for different calendars.

  ## Examples

      iex> GoodTimes.beginning_of_month(~U[2022-01-13 14:07:06.098765Z])
      ~U[2022-01-01 00:00:00Z]
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
  Accepts a DateTime-like map and returns a DateTime pointing to the end of the
  month in which that input DateTime falls. It uses the original Calendar to do
  that, so it should work for different calendars.

  ## Examples

      iex> GoodTimes.end_of_month(~U[2022-01-13 14:07:06.098765Z])
      ~U[2022-01-31 23:59:59.999999Z]
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
  Accepts a DateTime-like map and returns a DateTime pointing to the start of
  the year in which that input DateTime falls. It uses the original Calendar to
  do that, so it should work for different calendars.

  ## Examples

      iex> GoodTimes.beginning_of_year(~U[2022-01-13 14:07:06.098765Z])
      ~U[2022-01-01 00:00:00Z]
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
  Accepts a DateTime-like map and returns a DateTime pointing to the end of the
  year in which that input DateTime falls. It uses the original Calendar to do
  that, so it should work for different calendars.

  ## Examples

      iex> GoodTimes.end_of_year(~U[2022-01-13 14:07:06.098765Z])
      ~U[2022-12-31 23:59:59.999999Z]
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
