defmodule AdventOfCode.Solution.Year2024.Day01 do
  use AdventOfCode.Solution.SharedParse

  @spec get_pairs(binary()) :: {list(), list()}
  def get_pairs(input) do
    {left, right} = input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.map(&List.to_tuple/1)
    |> Enum.unzip()

    {Enum.sort(left), Enum.sort(right)}
  end

  def parse(input) do
    get_pairs(input)
  end

  def part1({left, right}) do

    left
    |> Enum.zip(right)
    |> Enum.map(fn {l, r} ->
      r - l
      |> abs()
    end)
    |> Enum.sum()
  end

  def part2({left, right}) do

    left
    |> Enum.map(fn d ->
      found = right
      |> Enum.filter(fn x -> x === d end)
      |> length()

      d * found
    end)
    |> Enum.sum()
  end
end
