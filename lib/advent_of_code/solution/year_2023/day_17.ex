defmodule AdventOfCode.Solution.Year2023.Day17 do

  use AdventOfCode.Solution.SharedParse

  defp get_neighbours({x, y, s}, map) do
    neighbours = case s do
      {:unknown, _} ->
        [
          {x + 1, y, {:east, 1}},
          {x - 1, y, {:west, 1}},
          {x, y + 1, {:south, 1}},
          {x, y - 1, {:north, 1}}
        ]

      {:north, c} when c < 3 ->
        [
          {x, y - 1, {:north, c + 1}},
          {x + 1, y, {:east, 1}},
          {x - 1, y, {:west, 1}}
        ]

      {:north, _} ->
        [
          {x + 1, y, {:east, 1}},
          {x - 1, y, {:west, 1}}
        ]

      {:south, c} when c < 3 ->
        [
          {x, y + 1, {:south, c + 1}},
          {x + 1, y, {:east, 1}},
          {x - 1, y, {:west, 1}}
        ]

      {:south, _} ->
        [
          {x + 1, y, {:east, 1}},
          {x - 1, y, {:west, 1}}
        ]

      {:east, c} when c < 3 ->
        [
          {x + 1, y, {:east, c + 1}},
          {x, y - 1, {:north, 1}},
          {x, y + 1, {:south, 1}}
        ]

      {:east, _} ->
        [
          {x, y - 1, {:north, 1}},
          {x, y + 1, {:south, 1}}
        ]

      {:west, c} when c < 3 ->
        [
          {x - 1, y, {:west, c + 1}},
          {x, y - 1, {:north, 1}},
          {x, y + 1, {:south, 1}}
        ]

      {:west, _} ->
        [
          {x, y - 1, {:north, 1}},
          {x, y + 1, {:south, 1}}
        ]
    end
    neighbours
    |> Enum.filter(fn {x, y, _} -> Map.get(map, {x, y}) !== nil end)
  end

  defp get_neighbours2({x, y, s}, map) do
    neighbours = case s do
      {:unknown, _} ->
        [
          {x + 1, y, {:east, 1}},
          {x - 1, y, {:west, 1}},
          {x, y + 1, {:south, 1}},
          {x, y - 1, {:north, 1}}
        ]

      {:north, c} when c < 4 ->
        [
          {x, y - 1, {:north, c + 1}},
        ]

      {:north, c} when c < 10 ->
        [
          {x, y - 1, {:north, c + 1}},
          {x + 1, y, {:east, 1}},
          {x - 1, y, {:west, 1}}
        ]

      {:north, _} ->
        [
          {x + 1, y, {:east, 1}},
          {x - 1, y, {:west, 1}}
        ]

      {:south, c} when c < 4 ->
        [
          {x, y + 1, {:south, c + 1}},
        ]

      {:south, c} when c < 10 ->
        [
          {x, y + 1, {:south, c + 1}},
          {x + 1, y, {:east, 1}},
          {x - 1, y, {:west, 1}}
        ]

      {:south, _} ->
        [
          {x + 1, y, {:east, 1}},
          {x - 1, y, {:west, 1}}
        ]

      {:east, c} when c < 4 ->
        [
          {x + 1, y, {:east, c + 1}},
        ]

        {:east, c} when c < 10 ->
          [
            {x + 1, y, {:east, c + 1}},
            {x, y - 1, {:north, 1}},
            {x, y + 1, {:south, 1}}
          ]

      {:east, _} ->
        [
          {x, y - 1, {:north, 1}},
          {x, y + 1, {:south, 1}}
        ]

      {:west, c} when c < 4 ->
        [
          {x - 1, y, {:west, c + 1}},
        ]

        {:west, c} when c < 10 ->
          [
            {x - 1, y, {:west, c + 1}},
            {x, y - 1, {:north, 1}},
            {x, y + 1, {:south, 1}}
          ]

      {:west, _} ->
        [
          {x, y - 1, {:north, 1}},
          {x, y + 1, {:south, 1}}
        ]
    end
    neighbours
    |> Enum.filter(fn {x, y, _} -> Map.get(map, {x, y}) !== nil end)
  end

  def parse(input) do
    max_y = input |> String.split("\n", trim: true) |> length()
    max_x = input |> String.split("\n", trim: true) |> hd() |> String.length()

    map =
      input
      |> String.split("\n", trim: true)
      |> Stream.with_index()
      |> Enum.reduce([], fn {line, y}, acc ->
        line
        |> String.split("", trim: true)
        |> Stream.with_index()
        |> Enum.reduce(acc, fn {char, x}, acc ->
          [{{x, y}, String.to_integer(char)} | acc]
        end)
      end)
      |> Map.new()

      {map, max_x, max_y}
  end

  def part1({map, max_x, max_y}) do

    nbs = fn vertex -> get_neighbours(vertex, map) end
    dist = fn _, {x, y, _} -> Map.get(map, {x, y}, :infinity) |> abs() end
    h = fn {x, y, _} -> abs((max_x - x) + (max_y - y)) end
    success = fn {x, y, _} -> x === max_x - 1 and y === max_y - 1 end

    env = {
      nbs,
      dist,
      h
    }
    Astar.astar(
      env,
      {0, 0, {:unknown, 0}},
      success
    )
    |> Enum.reverse()
    |> tl()
    |> Enum.map(fn {x,y,_} -> Map.get(map, {x,y}) end)
    |> Enum.sum()
  end

  def part2({map, max_x, max_y}) do

    nbs = fn vertex -> get_neighbours2(vertex, map) end
    dist = fn _, {x, y, _} -> Map.get(map, {x, y}, :infinity) |> abs() end
    h = fn {x, y, _} -> abs((max_x - x) + (max_y - y)) end
    success = fn {x, y, _} -> x === max_x - 1 and y === max_y - 1 end

    env = {
      nbs,
      dist,
      h
    }
    Astar.astar(
      env,
      {0, 0, {:unknown, 0}},
      success
    )
    |> Enum.reverse()
    |> tl()
    |> Enum.map(fn {x,y,_} -> Map.get(map, {x,y}) end)
    |> Enum.sum()

  end
end
