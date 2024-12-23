defmodule AdventOfCode.Solution.Year2024.Day23 do
  use AdventOfCode.Solution.SharedParse

  def build_groups(set, connections, map) do
    connections
    |> Enum.reduce(set, fn n, acc ->
      new_connections = Map.get(map, n, [])

      if Enum.all?(acc, fn x -> Enum.member?(new_connections, x) end) do
        build_groups(MapSet.put(acc, n), new_connections, map)
      else
        acc
      end
    end)
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn line, acc ->
      [a, b] = line |> String.split("-", trim: true, parts: 2)

      acc
      |> Map.update(a, [b], &[b | &1])
      |> Map.update(b, [a], &[a | &1])
    end)
  end

  def part1(map) do
    map
    |> Enum.reduce([], fn {k, v}, acc ->
      new_sets =
        v
        |> Enum.map(fn n ->
          {n,
           Map.get(map, n, [])
           |> Enum.filter(fn m ->
             Map.get(map, m, []) |> Enum.member?(k)
           end)}
        end)
        |> Enum.flat_map(fn {n, m} ->
          Enum.map(m, fn x -> [k, n, x] |> Enum.sort() end)
        end)
        |> Enum.filter(fn [a, b, c] ->
          String.starts_with?(a, "t") || String.starts_with?(b, "t") ||
            String.starts_with?(c, "t")
        end)

      acc ++ new_sets
    end)
    |> MapSet.new()
    |> MapSet.size()
  end

  def part2(map) do
    map
    |> Enum.map(fn {k, v} ->
      build_groups(MapSet.new([k]), v, map)
    end)
    |> Enum.sort_by(&Enum.count(&1))
    |> Enum.reverse()
    |> hd()
    |> Enum.sort()
    |> Enum.join(",")
  end
end
