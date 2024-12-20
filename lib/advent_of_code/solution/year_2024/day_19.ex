defmodule AdventOfCode.Solution.Year2024.Day19 do
  use AdventOfCode.Solution.SharedParse

  use Agent

  defp check_design(design, patterns) do
    patterns
      |> Enum.reduce_while(false, fn pattern, _ ->
        if design === pattern do
          {:halt, true}
        else
          if String.starts_with?(design, pattern) and check_design(String.slice(design, String.length(pattern), String.length(design)), patterns) do
            {:halt, true}
          else
            {:cont, false}
          end
        end
      end)
  end

  defp get_all_designs(design, patterns) do
    memory = Agent.get(:patterns, & &1)

    if Map.has_key?(memory, design) do
      Map.get(memory, design)
    else
      total = patterns
      |> Enum.reduce(0, fn pattern, acc ->
        if design === pattern do
          acc + 1
        else
          if String.starts_with?(design, pattern) do
            acc + get_all_designs(String.slice(design, String.length(pattern), String.length(design)), patterns)
          else
            acc
          end
        end
      end)
      Agent.update(:patterns, &(Map.put(&1, design, total)))
      total
    end
  end

  def parse(input) do
    [patterns, designs] = input
    |> String.split("\n\n", trim: true, parts: 2)

    {
      patterns |> String.split(", ", trim: true),
      designs |> String.split("\n", trim: true)
    }
  end

  def part1({patterns, designs}) do
    designs
    |> Task.async_stream(fn design ->
      check_design(design, patterns)
    end)
    |> Enum.filter(fn {:ok, result} -> result end)
    |> length
  end

  def part2({patterns, designs}) do

    Agent.start_link(fn -> %{} end, name: :patterns)

    designs
    |> Task.async_stream(fn design ->
      get_all_designs(design, patterns)
    end)
    |> Enum.map(fn {:ok, count} -> count end)
    |> Enum.sum()
  end
end
