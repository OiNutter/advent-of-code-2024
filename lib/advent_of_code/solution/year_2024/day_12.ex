defmodule AdventOfCode.Solution.Year2024.Day12 do

  def calculate_perimeter([]), do: 0
  def calculate_perimeter(region) when length(region) === 1, do: 4
  def calculate_perimeter(region) do
    region
    |> Enum.reduce(0, fn {x, y}, sides ->
      found_sides = 0

      # top side
      found_sides = if !Enum.member?(region, {x, y-1}), do: found_sides + 1, else: found_sides

      # bottom side
      found_sides = if !Enum.member?(region, {x, y+1}), do: found_sides + 1, else: found_sides

      # left side
      found_sides = if !Enum.member?(region, {x-1, y}), do: found_sides + 1, else: found_sides

      # right side
      found_sides = if !Enum.member?(region, {x+1, y}), do: found_sides + 1, else: found_sides

      if x === 110 && y === 108 do
        IO.inspect(found_sides)
        IO.inspect(Enum.find_index(region, fn {nx,ny} -> nx === x && ny === y-1 end))
        IO.inspect(Enum.member?(region, {x, y-1}))
      end

      sides + found_sides
    end)

  end

  def build_region({x,y}, char, map, squares) do
    if x === 111 && y === 107 do
      IO.inspect(Map.get(map, {x,y}))
    end
    if !Map.get(map, {x,y}) || Map.get(map, {x,y}) !== char || Enum.member?(squares, {x,y}) do
      squares
    else

      Enum.reduce(-1..1, squares, fn dx, squares ->
        Enum.reduce(-1..1, squares, fn dy, squares ->
          if dx === dy do
            squares
          else
            #IO.inspect({dx, dy})
            new_x = x + dx
            new_y = y + dy

            MapSet.new(squares ++ build_region({new_x, new_y}, char, map, [{x,y} | squares])) |> MapSet.to_list()
          end

        end)
      end)
        # build_region({x,y-1}, char, Map.delete(map, {x,y}), [{x,y} | squares]) ++
        # build_region({x,y+1}, char, Map.delete(map, {x,y}), [{x,y} | squares]) ++
        # build_region({x-1,y}, char, Map.delete(map, {x,y}), [{x,y} | squares]) ++
        # build_region({x+1,y}, char, Map.delete(map, {x,y}), [{x,y} | squares]) ++
        # squares
    end
  end

  def part1(input) do
    map = input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, y}, map ->
      line
      |> String.split("", trim: true)
      |> Enum.with_index()
      |> Enum.reduce(map, fn {char, x}, map ->
        Map.put(map, {x,y}, char)
      end)
    end)

    IO.inspect(map_size(map))

    map
    |> Enum.reduce([], fn {coord, char}, groups ->
      if Enum.any?(groups, fn {group,_} -> MapSet.member?(group, coord) end) do
        groups
      else
        [{MapSet.new(build_region(coord, char, map, [])), char} | groups]
        |> List.flatten()
      end
    end)
    |> MapSet.new()
    #|> IO.inspect()
    |> Enum.reduce(0, fn {region, char}, cost ->

      if char === "K"  do
       IO.inspect(region)
       #IO.inspect({{MapSet.size(region), calculate_perimeter(region |> MapSet.to_list())}, char})
      end
      cost + (MapSet.size(region) * calculate_perimeter(region |> MapSet.to_list()))
    end)
  end

  def part2(_input) do
  end
end
