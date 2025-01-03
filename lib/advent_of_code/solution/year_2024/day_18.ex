defmodule AdventOfCode.Solution.Year2024.Day18 do


  defp get_neighbors({x,y},map, {max_x, max_y}) do
    [
      {x, y - 1},
      {x + 1, y},
      {x - 1, y},
      {x, y + 1}
    ]
    |> Enum.filter(fn coords -> x >= 0 and x < max_x and y >= 0 and y < max_y and not byte?(coords, map) end)
  end

  defp cost(_), do: 1

  defp byte?(coords, map) do
    Map.has_key?(map, coords)
  end

  defp find_path(start, map, {max_x, max_y}) do
    nbs = fn vertex -> get_neighbors(vertex, map, {max_x, max_y}) end
    cost = fn _, b -> cost(b) end
    h = fn {x, y,} -> (max_x - x) + (max_y - y) end
    success = fn {x, y} -> x === max_x - 1 and y === max_y - 1 end

    env = {
      nbs,
      cost,
      h
    }
    Astar.astar(
      env,
      start,
      success
    )
  end

  def part1(input) do

    max_y = 71
    max_x = 71

    positions = input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [x,y] = String.split(line, ",", trim: true) |> Enum.map(&String.to_integer/1)
      {x,y}
    end)

    start = {0,0}
    map = positions
    |> Enum.take(1024)
    |> Enum.map(fn position -> {position, :byte} end)
    |> Map.new

    (find_path(start, map, {max_x, max_y}) |> length()) - 1
  end

  def part2(input) do

    max_y = 71
    max_x = 71

    positions = input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [x,y] = String.split(line, ",", trim: true) |> Enum.map(&String.to_integer/1)
      {x,y}
    end)

    start = {0,0}

    {_, to_check} = positions |> Enum.split(1024)

    {_, blocker, _} = 1..length(to_check)
    |> Enum.reduce_while({floor(length(to_check)/2), :nil, 0}, fn _, {index, _, last} ->

        map = positions
        |> Enum.take(1024 + (index-1))
        |> Enum.map(fn position -> {position, :byte} end)
        |> Map.new

        path = find_path(start, map, {max_x, max_y})

        if path === :no_path do
          {:cont, {ceil((index-last)/2), :nil, index}}
        else
          coord = Enum.at(to_check, index)
          map = Map.put(map, coord, :byte)
          path = find_path(start, map, {max_x, max_y})

          if path === :no_path do
            {:halt, {index, coord, index}}
          else
            {:cont, {index + ceil(abs(last-index)/2), :nil, index}}
          end
        end

    end)

    blocker
  end
end
