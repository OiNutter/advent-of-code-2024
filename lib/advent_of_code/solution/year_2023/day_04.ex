defmodule AdventOfCode.Solution.Year2023.Day04 do

  def get_cards(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [a, b] = Regex.replace(~r/Card\s+(\d+): /, line, "")
      |> String.split("|", trim: true)

      winningNumbers = MapSet.new(
        b
        |> String.split(" ", trim: true)
        |> Enum.map(&String.to_integer/1)
      )

      myNumbers = MapSet.new(
        a
        |> String.split(" ", trim: true)
        |> Enum.map(&String.to_integer/1)
      )


      MapSet.intersection(myNumbers, winningNumbers)
      |> MapSet.size()
    end)
  end
  @spec part1(binary()) :: number()
  def part1(input) do
    input
    |> get_cards()
    |> Enum.map(fn matches -> if matches > 0, do: Integer.pow(2, matches-1), else: 0 end)
    |> Enum.sum()
  end

  def part2(input) do
    cards = input
    |> get_cards()

    counts = Range.new(0, length(cards))
    |> Enum.map(fn i -> {i, 1} end)
    IO.inspect(Map.new(counts))
    Enum.reduce(Enum.with_index(cards), Map.new(counts), fn { matches, i}, counts ->

      Range.new(0, matches)
      |> Enum.reduce(counts, fn n, counts ->
        IO.inspect(Map.get(counts, i))
        Map.update(counts, i+n, 0, &(&1 + Map.get(counts, i)))
      end)
    end)
    |> Map.values()
    |> Enum.sum()
  end
end
