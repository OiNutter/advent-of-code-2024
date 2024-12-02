defmodule AdventOfCode.Solution.Year2023.Day02 do

  def parse_counts(scores) do
    scores
    |> String.split(";", trim: true)
    |> Enum.map(fn set ->
      set
      |> String.split(",", trim: true)
      |> Enum.reduce(%{red: 0, blue: 0, green: 0}, fn c, acc ->
        %{"colour" => colour, "count" => count} = Regex.named_captures(~r/(?<count>\d+) (?<colour>red|blue|green){1}/, String.trim(c))

        case colour do
          "red" -> Map.update!(acc, :red, &(&1 + String.to_integer(count)))
          "blue" -> Map.update!(acc, :blue, &(&1 + String.to_integer(count)))
          "green" -> Map.update!(acc, :green, &(&1 + String.to_integer(count)))
        end

      end)
    end)
  end

  def parse_game(line) do
    [game, scores] = String.split(line, ":", trim: true)
    {id,_} = Integer.parse(String.replace_prefix(game, "Game ", ""))
    {id, parse_counts(scores)}
  end

  def get_max_counts(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      parse_game(line)
    end)
    |> Enum.map(fn {id, games} ->
      {id, Enum.reduce(games, %{red: 0, blue: 0, green: 0}, fn current, counts ->

        counts
        |> Map.update!(:red, fn existing -> if Map.get(current, :red) > existing, do: Map.get(current, :red), else: existing end)
        |> Map.update!(:blue, fn existing -> if Map.get(current, :blue) > existing, do: Map.get(current, :blue), else: existing end)
        |> Map.update!(:green, fn existing -> if Map.get(current, :green) > existing, do: Map.get(current, :green), else: existing end)
      end)}
    end)
  end
  def get_possible_games(games, required, comparison) do
    games
    |> Enum.filter(fn {_id, game} ->
      comparison.(Map.get(game, :red), Map.get(required, :red)) &&
      comparison.(Map.get(game, :blue), Map.get(required, :blue)) &&
      comparison.(Map.get(game, :green), Map.get(required, :green))
    end)
    |> Enum.map(fn {id, _game} -> id end)
  end

  def part1(input) do
    required = %{red: 12, blue: 14, green: 13}
    input
    |> get_max_counts()
    |> get_possible_games(required, fn a,b -> a <= b end)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> get_max_counts()
    |> Enum.map(fn {_id, game} ->
      Map.get(game, :red) * Map.get(game, :blue) * Map.get(game, :green)
    end)
    |> Enum.sum()

  end
end
