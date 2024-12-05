defmodule AdventOfCode.Solution.Year2024.Day05 do
  def get_rules_map(rules) do
    rules
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn line, rules ->
      {x, y} =
        String.split(line, "|", parts: 2, trim: true)
        |> List.to_tuple()

      Map.update(rules, y, [], & &1)
      |> Map.update(y, [], &[x | &1])
    end)
  end

  def get_middle(update) do
    middle =
      update
      |> length()
      |> div(2)

    Enum.at(update, middle)
  end

  def get_sorted(pages, rules_map) do
    pages
    |> Enum.sort(fn a, b ->
      rules = Map.get(rules_map, a, [])
      if Enum.member?(rules, b), do: false, else: true
    end)
  end

  def check_correct(line, rules_map, want_correct \\ true) do
      pages =
        line
        |> String.split(",", trim: true)

      sorted = get_sorted(pages, rules_map)

      if pages == sorted , do: want_correct, else: !want_correct
  end

  def part1(input) do
    [rules, updates] =
      input
      |> String.split("\n\n", trim: true, parts: 2)

    rules_map = get_rules_map(rules)

    updates
    |> String.split("\n", trim: true)
    |> Enum.filter(fn line -> check_correct(line, rules_map) end)
    |> Enum.map(fn update ->
      pages =
        String.split(update, ",", trim: true)
        |> Enum.map(&String.to_integer/1)

      get_middle(pages)
    end)
    |> Enum.sum()
  end

  def part2(input) do
    [rules, updates] =
      input
      |> String.split("\n\n", trim: true, parts: 2)

    rules_map = get_rules_map(rules)

    updates
    |> String.split("\n", trim: true)
    |> Enum.filter(fn line -> check_correct(line, rules_map, false) end)
    |> Enum.map(fn update ->
      pages =
        String.split(update, ",", trim: true)

      get_sorted(pages, rules_map)
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.map(&get_middle/1)
    |> Enum.sum()
  end
end
