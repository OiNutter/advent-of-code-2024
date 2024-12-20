defmodule AdventOfCode.Solution.Year2023.Day08 do

  use AdventOfCode.Solution.SharedParse

  defp navigate(current, target, step, count, instructions, nodes) do
    if current == target do
      count
    else
      {left, right} = Map.get(nodes, current)
      new_node = if instructions |> Enum.at(step) == ?L, do: left, else: right
      next_step = if step + 1 >= instructions |> length, do: 0, else: step + 1
      navigate(new_node, target, next_step, count + 1, instructions, nodes)
    end
  end

  defp navigate2(current_nodes, step, counts, instructions, nodes) do
    if current_nodes |> Enum.filter(fn n -> not String.ends_with?(n, "Z") end) |> Enum.empty?() do
      counts
    else
      {new_nodes, new_counts} = current_nodes
      |> Enum.with_index()
      |> Enum.reduce({[], counts}, fn {n, i}, {new_nodes, counts} ->
        if String.ends_with?(n, "Z") do
          {[n | new_nodes], counts}
        else
          {left, right} = Map.get(nodes, n)
          n = if instructions |> Enum.at(step) == ?L, do: left, else: right
          {[n | new_nodes], Map.update(counts, i, 1, &(&1 + 1))}
        end
      end)

      next_step = if step + 1 >= instructions |> length, do: 0, else: step + 1
      navigate2(new_nodes |>  Enum.reverse(), next_step, new_counts, instructions, nodes)
    end
  end
  def parse(input) do
    [instructions, nodes] = input
    |> String.split("\n\n", trim: true, parts: 2)

    {
      instructions |> String.to_charlist(),
      nodes
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        %{"label" => label, "left" => left, "right" => right} = Regex.named_captures(~r/(?<label>[0-9A-Z]{3}) = \((?<left>[0-9A-Z]{3}), (?<right>[0-9A-Z]{3})\)/, line)
        {label, {left, right}}
      end)
      |> Map.new()
    }
  end

  def part1({instructions, nodes}) do
    navigate("AAA", "ZZZ", 0, 0, instructions, nodes)
  end

  def part2({instructions, nodes}) do
    current_nodes = nodes |> Map.keys() |> Enum.filter((fn n -> String.ends_with?(n, "A") end))

    navigate2(
      current_nodes,
      0,
      %{},
      instructions,
      nodes
    )
    |> Map.values()
    |> Enum.reduce(1, fn a, b -> BasicMath.lcm(a, b) end)


  end
end
