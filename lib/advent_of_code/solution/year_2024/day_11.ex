defmodule AdventOfCode.Solution.Year2024.Day11 do
  use AdventOfCode.Solution.SharedParse

  def change_stone("0"), do: ["1"]
  def change_stone(stone) do
    if rem(String.length(stone), 2) == 0 do
      String.split_at(stone, trunc(String.length(stone)/2)) |> Tuple.to_list() |> Enum.map(fn a -> String.to_integer(a) |> Integer.to_string() end)
    else
      [String.to_integer(stone) * 2024 |> Integer.to_string()]
    end
  end

  def blink(stones) do
    Enum.reduce(stones, %{}, fn {stone, count}, new_stones ->
      change_stone(stone)
      |> Enum.reduce(new_stones, fn new_stone, new_stones ->
        Map.update(new_stones, new_stone, count, &(&1 + count))
      end)
    end)
  end

  def parse_input(input) do
    input
    |> String.trim_trailing()
    |> String.split(" ", trim: true)
  end

  def parse(input) do
    parse_input(input)
    |> Enum.reduce(%{}, fn stone, stones -> Map.update(stones, stone, 1, &(&1 + 1)) end)
  end

  def part1(stones) do
    1..25
    |> Enum.reduce(stones, fn _, stones -> blink(stones) end)
    |> Map.values()
    |> Enum.sum()

  end

  def part2(stones) do
    1..75
    |> Enum.reduce(stones, fn _, stones -> blink(stones) end)
    |> Map.values()
    |> Enum.sum()
  end
end
