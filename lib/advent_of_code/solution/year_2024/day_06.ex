defmodule AdventOfCode.Solution.Year2024.Day06 do

  def move_guard({start_x, start_y}, map, steps, {dx, dy}, check_loop \\ false) do

    next_square = {start_x + dx, start_y + dy}
    next_val = Map.get(map, next_square, "@")
    next_delta = if next_val === "#", do: turn_guard({dx, dy}), else: {dx, dy}
    store_val = if check_loop, do: {next_square, next_delta}, else: next_square

    in_set? = MapSet.member?(steps, {next_square, next_delta})

    if check_loop && in_set? do
      1
    else
      case next_val do
        "#" -> move_guard({start_x, start_y}, map, steps, next_delta, check_loop)
        "." -> move_guard(next_square, map, MapSet.put(steps, store_val), next_delta, check_loop)
        _ -> if check_loop, do: 0, else: steps
      end
    end


  end

  def turn_guard(delta) do
    case delta do
      {0,-1} -> {1, 0}
      {1, 0} -> {0, 1}
      {-1, 0} -> {0, -1}
      {0, 1} -> { -1, 0}
    end
  end

  def get_delta(char) do
    case char do
      "^" -> {0,-1}
      ">" -> {1, 0}
      "<" -> {-1,0}
      "v" -> {0,1}
    end
  end

  def get_map(input) do
    input
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
  end

  def find_start(map) do
    map
    |> Enum.find(fn {_key, val} -> val === "^" || val === ">" || val === "<" || val === "v" end)
    |> elem(0)
  end

  def part1(input) do
    map = get_map(input)

    start = find_start(map)

    move_guard(start, Map.put(map, start,"."), MapSet.new([start]), get_delta(Map.get(map, start)))
    |> MapSet.size()
  end

  def part2(input) do
    map = get_map(input)

    start = find_start(map)
    start_delta = get_delta(Map.get(map, start))

    map
    |> Map.put(start, ".")
    |> Enum.reduce(0, fn {k, v}, count ->
      if v === "." do
        returned = move_guard(start, Map.put(Map.put(map, k, "#"), start, "."), MapSet.new([{start, start_delta}]), start_delta, true)
        count + returned
      else
        count
      end
    end)
  end
end
