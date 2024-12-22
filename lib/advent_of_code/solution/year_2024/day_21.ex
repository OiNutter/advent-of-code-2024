defmodule AdventOfCode.Solution.Year2024.Day21 do
  use Memoize

  use AdventOfCode.Solution.SharedParse

  @numeric_keypad %{
    {0, 0} => "7",
    {1, 0} => "8",
    {2, 0} => "9",
    {0, 1} => "4",
    {1, 1} => "5",
    {2, 1} => "6",
    {0, 2} => "1",
    {1, 2} => "2",
    {2, 2} => "3",
    {0, 3} => nil,
    {1, 3} => "0",
    {2, 3} => "A"
  }

  @directional_keypad %{
    {0, 0} => nil,
    {1, 0} => "^",
    {2, 0} => "A",
    {0, 1} => "<",
    {1, 1} => "v",
    {2, 1} => ">"
  }

  defp cheapest_dir_pad([], _, _, cheapest), do: cheapest
  defmemop cheapest_dir_pad(queue, target, robots, cheapest) do
    [{sx, sy, c} | rest] = queue
    {tx, ty} = target
    if {sx, sy} === {tx, ty} do
      cost = cheapest_robot(["A" | c] |> Enum.reverse(), robots - 1)
      cheapest = min(cost, cheapest)

      cheapest_dir_pad(rest, {tx, ty}, robots, cheapest)
    else
      if {sx,sy} === {0,0} do
        cheapest_dir_pad(rest, {tx, ty}, robots, cheapest)
      else
        rest =
          cond do
            ty > sy -> [{sx, sy + 1, ["v" | c]} | rest]
            ty < sy -> [{sx, sy - 1, ["^" | c]} | rest]
            true -> rest
          end

        rest =
          cond do
            tx > sx -> [{sx + 1, sy, [">" | c]} | rest]
            tx < sx -> [{sx - 1, sy, ["<" | c]} | rest]
            true -> rest
          end

        cheapest_dir_pad(rest, {tx, ty}, robots, cheapest)
      end
    end
  end

  defp cheapest_robot(presses, 1), do: presses |> length()
  defp cheapest_robot(presses, robots) do
    {_, total} = presses
    |> Enum.reduce({{2,0}, 0}, fn press, {{sx,sy}, total} ->
      {{tx, ty}, _} = Enum.find(@directional_keypad, fn {_, v} -> v === press end)
      {
        {tx, ty},
        total + cheapest_dir_pad([{sx, sy, []}], {tx, ty}, robots, :infinity)
      }
    end)
    total
  end

  defp cheapest_num_pad([], _, _, cheapest), do: cheapest
  defmemop cheapest_num_pad(queue, target, keypads, cheapest) do
    [{sx,sy,c}| rest] = queue
    {tx, ty} = target
    if {sx,sy} === {tx,ty} do
      cost = cheapest_robot(["A" | c] |> Enum.reverse(), keypads)
      cheapest = min(cost, cheapest)

      cheapest_num_pad(rest, {tx,ty}, keypads, cheapest)
    else
      if {sx,sy} === {0,3} do
        cheapest_num_pad(rest, {tx,ty}, keypads, cheapest)
      else
        rest =
          cond do
            ty > sy -> [{sx, sy + 1, ["v" | c]} | rest]
            ty < sy -> [{sx, sy - 1, ["^" | c]} | rest]
            true -> rest
          end

        rest =
          cond do
            tx > sx -> [{sx + 1, sy, [">" | c]} | rest]
            tx < sx -> [{sx - 1, sy, ["<" | c]} | rest]
            true -> rest
          end

        cheapest_num_pad(rest, {tx,ty}, keypads, cheapest)
      end
    end
  end

  defp cheapest_sequence(code, keypads) do
    {_, total} = code
    |> Enum.reduce({{2,3}, 0}, fn press, {{sx,sy}, total} ->
      {{tx, ty}, _} = Enum.find(@numeric_keypad, fn {_, v} -> v === press end)
      {
        {tx, ty},
        total + cheapest_num_pad([{sx,sy,[]}], {tx, ty}, keypads, :infinity)
      }
    end)
    total
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
  end

  defp get_score(codes, keypads) do
    codes
    |> Enum.map(fn code ->
      keys = code |> String.split("", trim: true)

      sequence_length = cheapest_sequence(keys, keypads)
      numeric_value = code |> String.replace("A", "") |> String.to_integer()

      sequence_length * numeric_value
    end)
    |> Enum.sum()
  end

  def part1(codes) do
    get_score(codes, 3)
  end

  def part2(codes) do
    get_score(codes, 26)
  end
end
