defmodule AdventOfCode.Solution.Year2024.Day01 do

  def get_pairs(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{left: [], right: []}, fn line, acc ->
      digits = line
      |> String.split("   ")
      |> Enum.map(&String.to_integer/1)

      left = Map.get(acc, :left) ++ [Enum.at(digits, 0)] |> Enum.sort()
      right = Map.get(acc, :right) ++ [Enum.at(digits, 1)] |> Enum.sort()
      %{left: left, right: right}
    end)
  end

  def part1(input) do
    %{left: left, right: right} = get_pairs(input)

    left
    |> Enum.with_index()
    |> Enum.map(fn {d, i} ->
      Enum.at(right, i) - d
      |> abs()
    end)
    |> Enum.sum()
  end

  def part2(input) do
    %{left: left, right: right} = get_pairs(input)

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
