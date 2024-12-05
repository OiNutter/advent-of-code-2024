defmodule AdventOfCode.Solution.Year2023.Day06 do
  def part1(input) do
    {times, distances} = input
    |> String.split("\n", trim: true)
    |> Enum.reduce({[], []}, fn line, {times, distances} ->
      cond do
        String.starts_with?(line, "Time:") ->
          {String.replace(line, "Time:","")
          |> String.trim()
          |> String.split(~r/\s+/)
          |> Enum.map(&String.to_integer/1), distances}
        String.starts_with?(line, "Distance:") ->
          {times, String.replace(line, "Distance:","")
          |> String.trim()
          |> String.split(~r/\s+/)
          |> Enum.map(&String.to_integer/1)}
      end
    end)

    times
    |> Enum.with_index()
    |> Enum.map(fn {maxTime, n} ->
      1..maxTime
      |> Enum.reduce(%{}, fn i, travel ->
        remaining = maxTime - i
        distance = i * remaining
        if distance > Enum.at(distances, n), do: Map.put(travel, i, distance), else: travel
      end)
    end)
    |> Enum.map(fn race ->
      Map.keys(race)
      |> length()
    end)
    |> Enum.product()
  end

  def part2(input) do
    {maxTime, maxDistance} = input
    |> String.split("\n", trim: true)
    |> Enum.reduce({0, 0}, fn line, {times, distances} ->
      cond do
        String.starts_with?(line, "Time:") ->
          {String.replace(line, "Time:","")
          |> String.trim()
          |> String.split(~r/\s+/)
          |> Enum.join("")
          |> String.to_integer(), distances}
        String.starts_with?(line, "Distance:") ->
          {times, String.replace(line, "Distance:","")
          |> String.trim()
          |> String.split(~r/\s+/)
          |> Enum.join("")
          |> String.to_integer()}
      end
    end)

    startDistance = 1..maxTime
    |> Enum.reduce_while(nil, fn i, val ->
      remaining = maxTime - i
      distance = i * remaining
      if distance > maxDistance, do: {:halt, i}, else: {:cont, val}
    end)

  endDistance = (maxTime-1)..0//-1
  |>Enum.reduce_while(nil, fn i, val ->
    remaining = maxTime - i
    distance = i * remaining
    if distance > maxDistance, do: {:halt, i}, else: {:cont, val}
  end)

    endDistance-startDistance + 1
  end
end
