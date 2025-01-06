defmodule AdventOfCode.Solution.Year2023.Day11 do

  use AdventOfCode.Solution.SharedParse

  @galaxy ?#

  defp find_galaxies(map) do
    map
    |> Enum.with_index()
    |> Enum.reduce(MapSet.new(), fn {row, y}, acc ->
      row
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {cell, x}, acc ->
        if cell == @galaxy do
          MapSet.put(acc, {x, y})
        else
          acc
        end
      end)
    end)
  end

  defp find_empty_rows(map) do
    map
    |> Enum.with_index()
    |> Enum.reduce(MapSet.new(), fn {row, y}, acc ->
      if Enum.all?(row, fn cell -> cell != @galaxy end) do
        MapSet.put(acc, y)
      else
        acc
      end
    end)
  end

  defp find_empty_cols(map) do
    map
    |> Enum.zip_with(&Function.identity/1)
    |> Enum.with_index()
    |> Enum.reduce(MapSet.new(), fn {col, x}, acc ->
      if Enum.all?(col, fn cell -> cell != @galaxy end) do
        MapSet.put(acc, x)
      else
        acc
      end
    end)
  end

  defp manhattan_distance({sx, sy}, {tx, ty}) do
    abs(sx - tx) + abs(sy - ty)
  end

  defp get_distances(galaxies, empty_rows, empty_cols, expansion) do
    expansion = expansion - 1
    galaxies
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {{sx, sy}, i}, distances ->
      galaxies
      |> Enum.with_index()
      |> Enum.reduce(distances, fn {{tx, ty}, j}, distances ->
        key = {i,j}
        if i === j or Map.has_key?(distances, key) or Map.has_key?(distances, {j, i}) do
          distances
        else
          rows = empty_rows
          |> Enum.filter(fn y -> y > min(sy, ty) and y < max(sy, ty) end)
          |> length()

          cols = empty_cols
          |> Enum.filter(fn x -> x > min(sx, tx) and x < max(sx, tx) end)
          |> length()

          Map.put(distances, key, manhattan_distance({sx, sy}, {tx, ty}) + (expansion * rows) + (expansion * cols))
        end
      end)
    end)
    |> Map.values()
  end

  def parse(input) do
    map = input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_charlist/1)

    galaxies = find_galaxies(map)
    empty_rows = find_empty_rows(map)
    empty_cols = find_empty_cols(map)

    {galaxies, empty_rows, empty_cols}
  end

  def part1({galaxies, empty_rows, empty_cols}) do
    get_distances(galaxies, empty_rows, empty_cols, 2)
    |> Enum.sum()
  end

  def part2({galaxies, empty_rows, empty_cols}) do
    get_distances(galaxies, empty_rows, empty_cols, 1000000)
    |> Enum.sum()
  end
end
