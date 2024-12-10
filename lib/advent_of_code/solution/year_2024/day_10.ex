defmodule AdventOfCode.Solution.Year2024.Day10 do
  def get_neighbours({x,y}, _, _), do: [{x-1,y}, {x+1,y}, {x,y-1}, {x,y+1}]

  def find_paths(map, ends, current_path, start, max_x, max_y) do
    start_val = Map.get(map, start)
    get_neighbours(start, max_x, max_y)
    |> Enum.filter(fn {x,y} ->
      new_val = Map.get(map, {x,y})
      new_val != nil && new_val != "." && new_val - start_val === 1 && !MapSet.member?(current_path, {x,y})
    end)
    |> Enum.reduce(ends, fn {x,y}, ends ->
      new_path = MapSet.put(current_path, {x,y})
      if Map.get(map, {x,y}) === 9 do
        MapSet.put(ends, {x,y})
      else
        find_paths(map, ends, new_path, {x,y}, max_x, max_y)
      end
    end)

  end

  def find_distinct_paths(map, ends, current_path, start, max_x, max_y) do
    start_val = Map.get(map, start)
    get_neighbours(start, max_x, max_y)
    |> Enum.filter(fn {x,y} ->
      new_val = Map.get(map, {x,y})
      new_val != nil && new_val != "." && new_val - start_val === 1 && !MapSet.member?(current_path, {x,y})
    end)
    |> Enum.reduce(ends, fn {x,y}, ends ->
      new_path = MapSet.put(current_path, {x,y})
      if Map.get(map, {x,y}) === 9 do
        MapSet.put(ends, new_path)
      else
        find_distinct_paths(map, ends, new_path, {x,y}, max_x, max_y)
      end
    end)

  end

  def get_map(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce({%{}, 0, 0}, fn {line, y}, {map, _, max_y} ->

      {map, max_x} = line
        |> String.split("", trim: true)
        |> Enum.with_index()
        |> Enum.reduce({map, 0}, fn {char, x}, {map, max_x} ->
          val = if char === ".", do: char, else: String.to_integer(char)
          {Map.put(map, {x,y}, val), max_x+1}
        end)

      {map, max_x, max_y+1}
    end)
  end
  def part1(input) do
    {map, max_x, max_y} = get_map(input)

    Enum.filter(map, fn {_, val} -> val === 0 end)
    |> Enum.map(fn {key, _} ->
      find_paths(map, MapSet.new(), MapSet.new([key]), key, max_x, max_y)
      |> MapSet.size()
    end)
    |> Enum.sum()
  end

  def part2(input) do
    {map, max_x, max_y} = get_map(input)

    Enum.filter(map, fn {_, val} -> val === 0 end)
    |> Enum.map(fn {key, _} ->
      find_distinct_paths(map, MapSet.new(), MapSet.new([key]), key, max_x, max_y)
      |> MapSet.size()
    end)
    |> Enum.sum()
  end
end
