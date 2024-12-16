defmodule AdventOfCode.Solution.Year2024.Day15 do
  def parse_map(map, false) do
    map
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      line
      |> String.split("", trim: true)
      |> Enum.with_index()
      |> Enum.map(fn {cell, x} -> {{x, y}, cell} end)
    end)
    |> Enum.into(%{})
  end

  def parse_map(map, true) do
    {map, _} = map
    |> String.split("\n", trim: true)
    |> Enum.reduce({[], 0}, fn line, {acc, y} ->
      {row, _} =
        line
        |> String.split("", trim: true)
        |> Enum.reduce({[], 0}, fn cell, {acc, x} ->
          case cell do
            "#" -> {acc ++ [{{x, y}, "#"}, {{x + 1, y}, "#"}], x + 2}
            "O" -> {acc ++ [{{x, y}, "["}, {{x + 1, y}, "]"}], x + 2}
            "@" -> {acc ++ [{{x, y}, "@"}, {{x + 1, y}, "."}], x + 2}
            _ -> {acc ++ [{{x, y}, "."}, {{x+1, y}, "."}], x + 2}
          end
        end)

      {acc ++ row, y + 1}
    end)

    map
    |> List.flatten()
    |> Enum.into(%{})
  end

  def parse_instructions(instructions) do
    instructions
    |> String.split("\n", trim: true)
    |> Enum.flat_map(&String.split(&1, "", trim: true))
  end

  def parse_input(input, double_size \\ false) do
    [map, instructions] =
      input
      |> String.split("\n\n", trim: true, parts: 2)

    {parse_map(map, double_size), parse_instructions(instructions)}
  end

  def move(map, {x, y}, {dx, dy}, char) do
    {new_x, new_y} = {x + dx, y + dy}
    new_cell = Map.get(map, {new_x, new_y}, "#")

    case new_cell do
      "#" ->
        {map, {x, y}}

      "[" ->
        {new_map, new_right_box} = move(map, {new_x + 1, new_y}, {dx, dy}, "]")

        if new_right_box == {new_x + 1, new_y} do
          {map, {x, y}}
        else
          {new_map, new_box} = move(new_map, {new_x, new_y}, {dx, dy}, "[")

          if new_box == {new_x, new_y} do
            {map, {x, y}}
          else
            {
              Map.put(new_map, {x, y}, ".") |> Map.put({new_x, new_y}, char),
              {new_x, new_y}
            }
          end
        end
      "]" ->
        {new_map, new_left_box} = move(map, {new_x - 1, new_y}, {dx, dy}, "[")

        if new_left_box == {new_x - 1, new_y} do
          {map, {x, y}}
        else
          {new_map, new_box} = move(new_map, {new_x, new_y}, {dx, dy}, "]")

          if new_box == {new_x, new_y} do
            {map, {x, y}}
          else
            {
              Map.put(new_map, {x, y}, ".") |> Map.put({new_x, new_y}, char),
              {new_x, new_y}
            }
          end
        end
      "O" ->
        {new_map, new_box} = move(map, {new_x, new_y}, {dx, dy}, "O")

        if new_box == {new_x, new_y} do
          {map, {x, y}}
        else
          {
            Map.put(new_map, {x, y}, ".") |> Map.put({new_x, new_y}, char),
            {new_x, new_y}
          }
        end

      _ ->
        {
          Map.put(map, {x, y}, ".") |> Map.put({new_x, new_y}, char),
          {new_x, new_y}
        }
    end
  end

  def part1(input) do
    {map, instructions} = parse_input(input)

    robot_start =
      Enum.find(map, fn {_, cell} -> cell == "@" end)
      |> elem(0)

    {updated_map, _} =
      instructions
      |> Enum.reduce({map, robot_start}, fn instruction, {map, robot_start} ->
        case instruction do
          "^" -> move(map, robot_start, {0, -1}, "@")
          "v" -> move(map, robot_start, {0, 1}, "@")
          "<" -> move(map, robot_start, {-1, 0}, "@")
          ">" -> move(map, robot_start, {1, 0}, "@")
          _ -> {map, robot_start}
        end
      end)

    updated_map
    |> Map.filter(fn {_, cell} -> cell == "O" end)
    |> Enum.map(fn {{x, y}, _} -> x + 100 * y end)
    |> Enum.sum()
  end

  def part2(input) do
    {map, instructions} = parse_input(input, true)

    robot_start =
      Enum.find(map, fn {_, cell} -> cell == "@" end)
      |> elem(0)

    {updated_map, _} =
      instructions
      |> Enum.reduce({map, robot_start}, fn instruction, {map, robot_start} ->
        case instruction do
          "^" -> move(map, robot_start, {0, -1}, "@")
          "v" -> move(map, robot_start, {0, 1}, "@")
          "<" -> move(map, robot_start, {-1, 0}, "@")
          ">" -> move(map, robot_start, {1, 0}, "@")
          _ -> {map, robot_start}
        end
      end)

    updated_map
    |> Map.filter(fn {_, cell} -> cell == "[" end)
    |> Enum.map(fn {{x, y}, _} -> x + 100 * y end)
    |> Enum.sum()
  end
end
