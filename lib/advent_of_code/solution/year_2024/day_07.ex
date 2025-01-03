defmodule AdventOfCode.Solution.Year2024.Day07 do
  def do_sum(current, [], target, _, _), do: current === target

  def do_sum(current, [next | rest], target, operator, operators) do
    new_value =
      case operator do
        :+ -> current + next
        :* -> current * next
        :|| -> String.to_integer("#{current}#{next}")
      end

    if new_value > target do
      false
    else
      if new_value === target and Enum.empty?(rest) do
        true
      else
        Enum.reduce_while(operators, false, fn operator, is_correct? ->
          if do_sum(new_value, rest, target, operator, operators) do
            {:halt, true}
          else
            {:cont, is_correct?}
          end
        end)
      end
    end
  end

  def analyse(input, operators) do
    input
    |> String.split("\n", trim: true)
    |> Enum.filter(fn line ->
      [answer, values] =
        line
        |> String.split(":", trim: true, parts: 2)

      test_value = String.to_integer(answer)

      inputs =
        values
        |> String.split(" ", trim: true)
        |> Enum.map(&String.to_integer/1)

      [start | new_values] = inputs

      Enum.reduce_while(operators, false, fn operator, is_correct? ->
        if do_sum(start, new_values, test_value, operator, operators) do
          {:halt, true}
        else
          {:cont, is_correct?}
        end
      end)
    end)
    |> Enum.map(fn line ->
      [answer, _] =
        line
        |> String.split(":", trim: true, parts: 2)

      String.to_integer(answer)
    end)
    |> Enum.sum()
  end

  def part1(input) do
    analyse(input, [:+, :*])
  end

  def part2(input) do
    analyse(input, [:+, :*, :||])
  end
end
