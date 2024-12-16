defmodule AdventOfCode.Solution.Year2024.Day16 do
  defp forward(map, finish, score, current, direction, passed) do
    next = add(current, direction)
    if (not wall?(next, map)) and next !== finish and wall?(add(next, turn_left(direction)), map) and wall?(add(next, turn_right(direction)), map) do
      forward(map, finish, score+1, next, direction, [next|passed])
    else
      {score + 1, next, direction, passed}
    end
  end

  defp rotations(map, score, current, direction, passed) do
    [
      {score+1000, current, turn_left(direction), passed},
      {score+1000, current, turn_right(direction), passed}
    ] |> Enum.reject(fn {_, current, direction, _} -> wall?(add(current, direction), map) end)
  end

  defp extend_paths([], _, paths, _), do: paths
  defp extend_paths([{score, current, direction, passed} | rest], map, paths, visited) do
    cond do
      wall?(current, map) -> extend_paths(rest, map, paths, visited)
      MapSet.member?(visited, {current, direction}) -> extend_paths(rest, map, paths, visited)
      true ->
        paths = :gb_sets.add({score, current, direction, passed}, paths)
        extend_paths(rest, map, paths, visited)
    end
  end

  defp turn_left({dx, dy}) do
    {dy, -dx}
  end

  defp turn_right({dx, dy}) do
    {-dy, dx}
  end

  defp add({x,y}, {dx, dy}) do
    {x + dx, y + dy}
  end
  def next(paths) do
    case :gb_sets.is_empty(paths) do
      true -> nil
      false ->
       :gb_sets.take_smallest(paths)
    end
  end

  def pathfind(paths, finish, map, visited, max_cost) do
    #IO.inspect(paths)
    case next(paths) do
      nil  -> []
      {{score, ^finish, _direction, _passed}, _paths} when max_cost === nil ->
        score
      {{score, ^finish, _direction, passed}, paths} ->
        if score <= max_cost do
          max_cost = min(max_cost, score)
          passed = [finish | passed]
          [passed | pathfind(paths, finish, map, visited, max_cost)]
        else
          []
        end
        {{score, current, direction, passed}, paths} ->
          visited = MapSet.put(visited, {current, direction})
          passed = case passed do
            [^current | _] -> passed
            _ when max_cost === nil -> [current]
            _ -> [current | passed]
          end

          new_paths = [
            forward(map, finish, score, current, direction, passed) | rotations(map, score, current, direction, passed)
          ]
          |> extend_paths(map, paths, visited)
          pathfind(new_paths, finish, map, visited, max_cost)
    end
  end

  def parse_input(input) do
    input
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.flat_map(fn {line,y} ->

        line
        |> String.to_charlist()
        |> Enum.with_index()
        |> Enum.flat_map(fn {char, x} ->
          [{{x,y}, char}]
        end)

      end)
      |> Map.new
  end

  defp wall?(coords, map) do
    Map.get(map, coords, ?\#) === ?\#
  end

  def find_ends(map) do
    start = Enum.find(map, fn {_, v} -> v == ?S end) |> elem(0)
    finish = Enum.find(map, fn {_, v} -> v == ?E end) |> elem(0)
    {start, finish}
  end

  def part1(input) do
    map = parse_input(input)

    {start, finish} = find_ends(map)

    :gb_sets.singleton({0, start, {1,0}, []})
    |> pathfind(finish, map, MapSet.new(), :nil)
  end

  def part2(input) do
    map = parse_input(input)

    {start, finish} = find_ends(map)

    :gb_sets.singleton({0, start, {1,0}, []})
    |> pathfind(finish, map, MapSet.new(), :infinity)
    |> Enum.map(&:ordsets.from_list/1)
    |> :ordsets.union
    |> length

  end
end
