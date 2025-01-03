defmodule AdventOfCode.Solution.Year2024.Day20 do
  use AdventOfCode.Solution.SharedParse

  defp wall?(coords, map) do
    Map.get(map, coords, ?\#) === ?\#
  end

  defp get_distance([], _, distances, _, _), do: distances

  defp get_distance([{sx, sy, d} | rest], {ex, ey}, distances, visited, map) do
    if {sx, sy} == {ex, ey} do
      get_distance(rest, {ex, ey}, distances, visited, map)
    else
      new_visited = MapSet.put(visited, {sx, sy})

      {new_distances, new_queue} =
        [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]
        |> Enum.reduce({distances, rest}, fn {dx, dy}, {distances_acc, rest_acc} ->
          {new_x, new_y} = {sx + dx, sy + dy}

          if not wall?({new_x, new_y}, map) do
            if not Map.has_key?(distances_acc, {new_x, new_y}) do
              distances_acc = Map.put(distances_acc, {new_x, new_y}, d + 1)

              new_queue =
                if not MapSet.member?(new_visited, {new_x, new_y}),
                  do: rest_acc ++ [{new_x, new_y, d + 1}],
                  else: rest_acc

              {distances_acc, new_queue}
            else
              {distances_acc, rest_acc}
            end
          else
            {distances_acc, rest_acc}
          end
        end)

      get_distance(new_queue, {ex, ey}, new_distances, new_visited, map)
    end
  end

  defp find_shortcuts(map, distances, max_cheating) do
    distances
    |> Enum.reduce(0, fn {{x, y}, cost}, acc ->
      if cost <= 100 do
        acc
      else
        -max_cheating..max_cheating
        |> Enum.reduce(acc, fn dy, acc ->
          -max_cheating..max_cheating
          |> Enum.reduce(acc, fn dx, acc ->
            manhattan_distance = abs(dx) + abs(dy)

            if manhattan_distance <= max_cheating and manhattan_distance > 0 do
              {new_x, new_y} = {x + dx, y + dy}

              if wall?({new_x, new_y}, map) do
                acc
              else
                cost_2 = Map.get(distances, {new_x, new_y})

                if cost_2 === nil do
                  acc
                else
                  saving = cost - cost_2 - manhattan_distance
                  if saving >= 100, do: acc + 1, else: acc
                end
              end
            else
              acc
            end
          end)
        end)
      end
    end)
  end

  def find_ends(map) do
    start = Enum.find(map, fn {_, v} -> v == ?S end) |> elem(0)
    finish = Enum.find(map, fn {_, v} -> v == ?E end) |> elem(0)
    {start, finish}
  end

  def parse(input) do
    map =
      input
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.flat_map(fn {line, y} ->
        line
        |> String.to_charlist()
        |> Enum.with_index()
        |> Enum.map(fn {char, x} ->
          {{x, y}, char}
        end)
      end)
      |> Map.new()

    {{start_x, start_y}, finish} = find_ends(map)

    distances = get_distance([{start_x, start_y, 0}], finish, %{}, MapSet.new(), map)

    {
      map,
      distances
    }
  end

  def part1({map, path}) do
    find_shortcuts(map, path, 2)
  end

  def part2({map, path}) do
    find_shortcuts(map, path, 20)
  end
end
