defmodule AdventOfCode.Solution.Year2023.Day09 do

  use AdventOfCode.Solution.SharedParse

  defp finished?(step) do
    step
    |> Enum.filter(fn x -> x !== 0 end)
    |> length() === 0
  end

  defp perform_step(steps) do
    prev = steps |> hd()
    if finished?(prev) do
      steps
    else
      [prev_start | prev_step] = prev
      {new_step, _} = prev_step
      |> Enum.reduce({[], prev_start}, fn i, {acc, prev} ->
        {[i - prev | acc], i}
      end)
      perform_step([new_step |> Enum.reverse() | steps])
    end
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
  end
  def part1(sequences) do
    sequences
    |> Enum.map(fn sequence ->
      perform_step([sequence])
      |> tl()
      |> Enum.reduce(0, fn step, acc ->
        :lists.last(step) + acc
      end)

    end)
    |> Enum.sum()
  end

  def part2(sequences) do
    sequences
    |> Enum.map(fn sequence ->
      perform_step([sequence])
      |> tl()
      |> Enum.reduce(0, fn step, acc ->
        hd(step) - acc
      end)

    end)
    |> Enum.sum()
  end
end
