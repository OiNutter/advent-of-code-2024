defmodule AdventOfCode.Solution.Year2023.Day01 do

  def getValue(match) do
    %{
      "one" => 1,
      "two" => 2,
      "three" => 3,
      "four" => 4,
      "five" => 5,
      "six" => 6,
      "seven" => 7,
      "eight" => 8,
      "nine" => 9
    }
    |> Map.get(match, match)
  end

  def getValues(input, regex) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      digits = Regex.scan(regex, line, capture: :all)
      |> Enum.map(fn m ->
        Enum.at(m, 1)
      end)

      String.to_integer(~s(#{getValue(hd(digits))}#{getValue(:lists.last(digits))}))
    end)
    |> Enum.sum()


  end

  def part1(input) do
    getValues(input, ~r/(\d{1})/)
  end

  def part2(input) do
    getValues(input, ~r/(?=(one|two|three|four|five|six|seven|eight|nine|\d){1})/)
  end
end
