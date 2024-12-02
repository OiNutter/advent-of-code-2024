defmodule AdventOfCode.Solution.Year2024.Day02 do

  def check_safe(levels) do

    # increase or decrease
    increase = List.first(levels) < List.last(levels)

    start = List.first(levels)
    levels
    |> Enum.slice(1..-1//1)
    |> Enum.reduce_while(%{prev: start, safe: true}, fn level, acc ->
      %{prev: prev, safe: _safe} = acc
      difference = if increase, do: level - prev, else: prev - level
      if difference >= 1 && difference <= 3, do: {:cont, %{prev: level, safe: true}}, else: {:halt, %{safe: false, prev: prev}}
    end)
    |> Map.get(:safe)
  end

  def part1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)
      |> check_safe()
    end)
    |> Enum.filter(fn x -> x === true end)
    |> length()
  end

  def part2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      levels = line
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)

      safe = levels
      |> check_safe()

      if not safe do
        dampened = 0..length(levels)
        |> Enum.find(fn i ->
          levels
          |> List.delete_at(i)
          |> check_safe()
        end)

        !!dampened
      else
        safe
      end
    end)
    |> Enum.filter(fn x -> x === true end)
    |> length()
  end
end
