# GoodTimes

GoodTimes contains some helpful functions for operating on DateTime-like maps.
These are useful for rounding and bucketing times in a stable way.

Like the standard library, it operates on maps that have the set of keys that
are used by DateTime. Any other map/struct that has the same keys should work
with these functions.

## Included Functions

Generalized time bucketing function: 
 * `bucket/3`

Calendar-based bucketing functions:
 * `beginning_of_day/1`
 * `beginning_of_month/1`
 * `beginning_of_week/1`
 * `beginning_of_year/1`
 * `end_of_day/1`
 * `end_of_month/1`
 * `end_of_week/1`
 * `end_of_year/1`



## Installation

The package can be installed by adding `good_times` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:good_times, "~> 0.1.0"}
  ]
end
```
