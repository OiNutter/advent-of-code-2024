defmodule AdventOfCode.Solution.Year2024.Day25 do

  defp has_overlap?(lock, key) do
    key
    |> Enum.zip(lock)
    |> Enum.any?(fn {k, l} ->
      k + l > 5
    end)
  end
  def parse_group(group) do
    group
    |> String.split("\n", trim: true)
    |> Enum.reduce([-1,-1,-1,-1,-1], fn line, cols ->
      line
      |> String.to_charlist()
      |> Enum.with_index()
      |> Enum.reduce(cols, fn {char, i}, cols ->
        List.update_at(cols, i, &(&1 + (if char === ?#, do: 1, else: 0)))
      end)
    end)
  end

  def parse(input) do
    input
    |> String.split("\n\n", trim: true)
    |>Enum.reduce({[],[]}, fn group, {locks, keys} ->
      if (String.starts_with?(group, "#")) do
        {locks ++ [parse_group(group)], keys}
      else
        {locks, keys ++ [parse_group(group)]}
      end
    end)
  end

  def part1(input) do
    {locks, keys} = parse(input)

    locks
    |> Enum.reduce(MapSet.new(), fn lock, combos ->
      keys
      |> Enum.reduce(combos, fn key, combos ->
        if not has_overlap?(lock,key) do
          MapSet.put(combos, {lock, key})
        else
          combos
        end
      end)
    end)
    |> MapSet.size()
  end

  def part2(_input) do
  end
end
