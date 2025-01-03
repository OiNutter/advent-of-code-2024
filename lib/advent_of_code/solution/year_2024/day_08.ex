defmodule AdventOfCode.Solution.Year2024.Day08 do

  use AdventOfCode.Solution.SharedParse

  def add_antinode(antinodes, {start_x, start_y}, {dx, dy}, max_x, max_y) do
    x = start_x + dx
    y = start_y + dy

    if x >= 0 && x < max_x && y >= 0 && y < max_y do
     add_antinode([{x,y} | antinodes], {x, y}, {dx, dy}, max_x, max_y)
    else
      antinodes
    end
  end

  def parse(input) do
    max_y = Enum.count(input |> String.split("\n", trim: true))
    max_x = input |> String.split("\n", trim: true) |> List.first() |> String.length()

    map = input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, y}, map ->
      line
      |> String.to_charlist()
      |> Enum.with_index()
      |> Enum.reduce(map, fn {node, x}, map ->
        Map.put(map, {x,y}, node)
      end)
    end)

    {map, {max_x, max_y}}
  end

  def part1({map, {max_x, max_y}}) do

    # find antinodes
    map
    |> Enum.reduce([], fn {{x,y}, node}, antinodes ->
      if node !== ?. do
        # find matching frequencies
        new_nodes = map
        |> Enum.filter(fn {{x2, y2}, node2} -> node2 === node && x2 !== x && y2 !== y end)
        |> Enum.flat_map((fn {{x2,y2}, _} ->
          dx = x2 - x
          dy = y2 - y

          [{x - dx, y - dy}, {x2 + dx, y2 + dy}]
        end))
        |> Enum.filter(fn {anti_x, anti_y} ->
          anti_x >= 0 && anti_x < max_x && anti_y >= 0 && anti_y < max_y
        end)

        new_nodes ++ antinodes

      else
        antinodes
      end
    end)
    |> MapSet.new()
    |> MapSet.size()
  end

  def part2({map, {max_x, max_y}}) do

    # find antinodes
    map
    |> Enum.reduce([], fn {{x,y}, node}, antinodes ->
      if node !== ?. do
        # find matching frequencies
        new_nodes = map
        |> Enum.filter(fn {{x2, y2}, node2} -> node2 === node && x2 !== x && y2 !== y end)
        |> Enum.flat_map((fn {{x2,y2}, _} ->
          dx = x2 - x
          dy = y2 - y

          [{x, y}, {x2,y2}] ++ add_antinode([], {x, y}, {-dx, -dy}, max_x, max_y) ++ add_antinode([], {x2, y2}, {dx, dy}, max_x, max_y)
        end))

        new_nodes ++ antinodes
      else
        antinodes
      end
    end)
    |> MapSet.new()
    |> MapSet.size()
  end
end
