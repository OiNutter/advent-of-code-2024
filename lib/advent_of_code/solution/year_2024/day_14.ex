defmodule AdventOfCode.Solution.Year2024.Day14 do
  def parse_robot(line) do
    %{"p" => p, "v" => v} = Regex.named_captures(~r/p=(?<p>.+) v=(?<v>.+)/, line)

    {
      String.split(p, ",", trim: true) |> Enum.map(&String.to_integer/1) |> List.to_tuple(),
      String.split(v, ",", trim: true) |> Enum.map(&String.to_integer/1) |> List.to_tuple()
    }
  end

  def part1(input) do
    robots = input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_robot/1)

    max_x = 101#11
    max_y = 103#7

    mid_x = floor(max_x / 2)
    mid_y = floor(max_y / 2)

    robots
    |> Enum.map(fn {p, {vx, vy}} ->
     # IO.inspect("===")
      #IO.inspect({p, {vx, vy}})
      Enum.reduce(1..100, p, fn _, {px, py} ->
        new_x = px + vx
        new_y = py + vy

        new_x = if new_x < 0, do: max_x + new_x, else: new_x
        new_x = if new_x >= max_x, do: 0 + (new_x - max_x), else: new_x

        new_y = if new_y < 0, do: max_y + new_y, else: new_y
        new_y = if new_y >= max_y, do: 0 + (new_y - max_y), else: new_y

        #IO.inspect({new_x, new_y})
        {new_x, new_y}
      end)
    end)
    |> Enum.reduce(%{ne: [], nw: [], se: [], sw: []}, fn {x, y}, acc ->

      acc = if x > mid_x && y > mid_y, do: Map.update(acc, :se, [{x, y}], &(&1 ++ [{x, y}])), else: acc
      acc = if x < mid_x && y > mid_y, do: Map.update(acc, :sw, [{x, y}], &(&1 ++ [{x, y}])), else: acc
      acc = if x > mid_x && y < mid_y, do: Map.update(acc, :ne, [{x, y}], &(&1 ++ [{x, y}])), else: acc
      acc = if x < mid_x && y < mid_y, do: Map.update(acc, :nw, [{x, y}], &(&1 ++ [{x, y}])), else: acc

      acc
    end)
    |> Map.values()
    |> Enum.map(&length/1)
    |> Enum.product()

  end

  def part2(input) do
    robots = input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_robot/1)

    max_x = 101#11
    max_y = 103#7

    {_, seconds} = 1..(max_x * max_y)
    |> Enum.reduce_while({robots, 0}, fn n, {robots, _} ->
      robots = robots
      |> Enum.map(fn {{px, py}, {vx, vy}} ->
        new_x = px + vx
        new_y = py + vy

        new_x = if new_x < 0, do: max_x + new_x, else: new_x
        new_x = if new_x >= max_x, do: 0 + (new_x - max_x), else: new_x

        new_y = if new_y < 0, do: max_y + new_y, else: new_y
        new_y = if new_y >= max_y, do: 0 + (new_y - max_y), else: new_y

        {{new_x, new_y}, {vx, vy}}
      end)

      map = Enum.reduce(robots, %{}, fn {{px, py}, _}, map ->
        Map.put(map, {px, py}, true)
      end)

      output = 0..max_y-1
      |> Enum.reduce(%{}, fn y, output ->
        output = 0..max_x-1
        |> Enum.reduce(output, fn x, output ->
          char = if Map.get(map, {x, y}), do: "#", else: "."
          Map.update(output, y, [char], &(&1 ++ [char]))
        end)

        output
      end)

      rows = output
      |> Enum.reduce([], fn {_, row}, rows->
        rows ++ [Enum.join(row)]
      end)

      if Enum.find(rows, fn row ->
        Regex.match?(~r/\#{30,}/, row)
      end) do
        # rows
        # |> Enum.with_index()
        # |> Enum.map(fn {row, i} ->
        #   IO.puts("#{String.pad_leading(Integer.to_string(i), 3)}: #{row}")
        # end)

        {:halt, {robots, n}}
      else
        {:cont, {robots, n + 1}}
      end
    end)

    seconds
  end
end
