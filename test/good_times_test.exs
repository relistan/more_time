defmodule GoodTimesTest do
  use ExUnit.Case
  doctest GoodTimes

  describe "when bucketing times" do
    test "it buckets to the right day" do
      for {input, count, unit, expected} <-
            [
              # input                          count unit    expected
              {~U[2021-01-13 14:07:06.098765Z], 1, :day, ~U[2021-01-13 00:00:00Z]},
              {~U[2021-01-13 14:07:06.098765Z], 5, :day, ~U[2021-01-13 00:00:00Z]},
              {~U[2021-01-23 21:49:06.098765Z], 5, :day, ~U[2021-01-23 00:00:00Z]},
              {~U[2021-01-30 02:23:06.098765Z], 7, :day, ~U[2021-01-28 00:00:00Z]},
              {~U[2021-02-17 14:53:06.098765Z], 23, :day, ~U[2021-01-26 00:00:00Z]}
            ] do
        assert GoodTimes.bucket(input, count, unit) == expected
      end
    end

    test "it buckets to the right hour" do
      for {input, count, unit, expected} <-
            [
              # input                          count unit    expected
              {~U[2021-01-13 14:07:06.098765Z], 1, :hour, ~U[2021-01-13 14:00:00Z]},
              {~U[2021-01-13 14:07:06.098765Z], 5, :hour, ~U[2021-01-13 10:00:00Z]},
              {~U[2021-01-13 21:49:06.098765Z], 5, :hour, ~U[2021-01-13 20:00:00Z]},
              {~U[2021-01-13 02:23:06.098765Z], 7, :hour, ~U[2021-01-12 20:00:00Z]},
              {~U[2021-01-13 14:53:06.098765Z], 23, :hour, ~U[2021-01-13 13:00:00Z]}
            ] do
        assert GoodTimes.bucket(input, count, unit) == expected
      end
    end

    test "it buckets to the right minute" do
      for {input, count, unit, expected} <-
            [
              # input                          count unit    expected
              {~U[2021-01-13 14:07:06.098765Z], 1, :minute, ~U[2021-01-13 14:07:00Z]},
              {~U[2021-01-13 14:07:06.098765Z], 5, :minute, ~U[2021-01-13 14:05:00Z]},
              {~U[2021-01-13 14:49:06.098765Z], 5, :minute, ~U[2021-01-13 14:45:00Z]},
              {~U[2021-01-13 14:23:06.098765Z], 7, :minute, ~U[2021-01-13 14:19:00Z]},
              {~U[2021-01-13 14:53:06.098765Z], 23, :minute, ~U[2021-01-13 14:32:00Z]}
            ] do
        assert GoodTimes.bucket(input, count, unit) == expected
      end
    end

    test "it buckets to the right second" do
      for {input, count, unit, expected} <-
            [
              # input                          count unit    expected
              {~U[2021-01-13 14:07:06.098765Z], 5, :second, ~U[2021-01-13 14:07:05Z]},
              {~U[2021-01-13 14:49:23.098765Z], 5, :second, ~U[2021-01-13 14:49:20Z]},
              {~U[2021-01-13 14:23:57.098765Z], 7, :second, ~U[2021-01-13 14:23:54Z]},
              {~U[2021-01-13 14:53:06.098765Z], 23, :second, ~U[2021-01-13 14:53:05Z]}
            ] do
        assert GoodTimes.bucket(input, count, unit) == expected
      end
    end
  end

  describe "when book-ending days" do
    test "it finds the start of the day" do
      assert GoodTimes.beginning_of_day(~U[2022-01-13 14:07:06.098765Z]) == ~U[2022-01-13 00:00:00Z]
    end

    test "it finds the end of the day" do
      assert GoodTimes.end_of_day(~U[2022-01-13 14:07:06.098765Z]) == ~U[2022-01-13 23:59:59.999999Z]
    end
  end

  describe "when book-ending weeks do" do
    test "it returns the end of the week" do
      for {input, expected} <-
            [
              {~U[2022-01-13 14:07:06.098765Z], ~U[2022-01-16 23:59:59.999999Z]},
              {~U[2011-12-31 01:07:06.123456Z], ~U[2012-01-01 23:59:59.999999Z]},
              {~U[2008-12-31 01:07:06.123456Z], ~U[2009-01-04 23:59:59.999999Z]}
            ] do
        assert GoodTimes.end_of_week(input) == expected
      end

      {:ok, dt, _offset} = DateTime.from_iso8601("2022-01-13T14:07:06.098765+0100")
      eow = GoodTimes.end_of_week(dt)

      assert eow == ~U[2022-01-16 23:59:59.999999Z]
    end

    test "it returns the beginning of the week" do
      for {input, expected} <-
            [
              {~U[2022-01-01 14:07:06.098765Z], ~U[2021-12-27 00:00:00Z]},
              {~U[2011-12-31 01:07:06.123456Z], ~U[2011-12-26 00:00:00Z]},
              {~U[2008-12-31 01:07:06.123456Z], ~U[2008-12-29 00:00:00Z]}
            ] do
        assert GoodTimes.beginning_of_week(input) == expected
      end
    end
  end

  describe "when book-ending months do" do
    test "it returns the end of the month" do
      for {input, expected} <-
            [
              {~U[2022-01-13 14:07:06.098765Z], ~U[2022-01-31 23:59:59.999999Z]},
              {~U[2011-12-31 01:07:06.123456Z], ~U[2011-12-31 23:59:59.999999Z]},
              {~U[2008-12-05 01:07:06.123456Z], ~U[2008-12-31 23:59:59.999999Z]}
            ] do
        assert GoodTimes.end_of_month(input) == expected
      end
    end

    test "it returns the beginning of the month" do
      for {input, expected} <-
            [
              {~U[2022-01-13 14:07:06.098765Z], ~U[2022-01-01 00:00:00Z]},
              {~U[2011-12-31 01:07:06.123456Z], ~U[2011-12-01 00:00:00Z]},
              {~U[2008-12-05 01:07:06.123456Z], ~U[2008-12-01 00:00:00Z]}
            ] do
        assert GoodTimes.beginning_of_month(input) == expected
      end
    end
  end

  describe "when book-ending years do" do
    test "it returns the end of the year" do
      for {input, expected} <-
            [
              {~U[2022-01-13 14:07:06.098765Z], ~U[2022-12-31 23:59:59.999999Z]},
              {~U[2011-12-31 01:07:06.123456Z], ~U[2011-12-31 23:59:59.999999Z]},
              {~U[2008-12-05 01:07:06.123456Z], ~U[2008-12-31 23:59:59.999999Z]}
            ] do
        assert GoodTimes.end_of_year(input) == expected
      end
    end

    test "it returns the beginning of the year" do
      for {input, expected} <-
            [
              {~U[2022-01-13 14:07:06.098765Z], ~U[2022-01-01 00:00:00Z]},
              {~U[2011-12-31 01:07:06.123456Z], ~U[2011-01-01 00:00:00Z]},
              {~U[2008-12-05 01:07:06.123456Z], ~U[2008-01-01 00:00:00Z]}
            ] do
        assert GoodTimes.beginning_of_year(input) == expected
      end
    end
  end
end
