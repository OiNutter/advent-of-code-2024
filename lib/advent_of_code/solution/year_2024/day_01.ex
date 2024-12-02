defmodule AdventOfCode.Solution.Year2024.Day01 do

  def get_pairs(input) do
    {left, right} = input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split/1)
    |> Enum.map(&List.to_tuple/1)
    |> Enum.map(fn {a, b} -> {String.to_integer(a), String.to_integer(b)} end)
    |> Enum.unzip()

    {Enum.sort(left), Enum.sort(right)}
  end

  def part1(input) do
    {left, right} = get_pairs(input)

    left
    |> Enum.with_index()
    |> Enum.map(fn {d, i} ->
      Enum.at(right, i) - d
      |> abs()
    end)
    |> Enum.sum()
  end

  def part2(input) do
    {left, right} = get_pairs(input)

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
