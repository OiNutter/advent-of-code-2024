defmodule AdventOfCode.Solution.Year2024.Day03 do
  def part1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.flat_map(fn line ->
      Regex.scan(~r/mul\([0-9]{1,3},[0-9]{1,3}\)/, line)
      |> Enum.map(fn sum ->
        [a, b] = Regex.scan(~r/([0-9]{1,3})/, List.first(sum), capture: :first)
        String.to_integer(List.first(a)) * String.to_integer(List.first(b))
      end)
    end)
    |> Enum.sum()
  end

  def part2(input) do
    {_, result} = input
    |> String.split("\n", trim: true)
    |> Enum.flat_map(fn line ->
      Regex.scan(~r/mul\([0-9]{1,3},[0-9]{1,3}\)|do\(\)|don't\(\)/, line)
      |> Enum.map(fn instruction ->
        List.first(instruction)
      end)
    end)
    |> Enum.reduce({true, 0}, fn instruction, {do_sums, result} ->
      case instruction do
        "do()" -> {true, result}
        "don't()" -> {false, result}
        _ ->
          if do_sums do
            [a, b] = Regex.scan(~r/([0-9]{1,3})/, instruction, capture: :first)
            prod = String.to_integer(List.first(a)) * String.to_integer(List.first(b))
            {true, result + prod}
          else
            {do_sums, result}
          end
      end
    end)
    result
  end

end
