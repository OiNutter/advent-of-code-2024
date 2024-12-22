defmodule AdventOfCode.Solution.Year2024.Day22 do
  use AdventOfCode.Solution.SharedParse
  use Memoize

  def mix(a, b) do
    Bitwise.bxor(a, b)
  end

  def prune(a) do
    rem(a, 16_777_216)
  end

  def generate_secret_number(n) do
    new_n = prune(mix(n * 64, n))
    new_n = prune(mix(floor(new_n / 32), new_n))
    prune(mix(new_n * 2048, new_n))
  end

  @spec parse(binary()) :: list()
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  @spec part1(any()) :: nil
  def part1(numbers) do
    numbers
    |> Enum.map(fn n ->
      1..2000
      |> Enum.reduce(n, fn _, n ->
        generate_secret_number(n)
      end)
    end)
    |> Enum.sum()
  end

  def part2(numbers) do
    sequences =
      numbers
      |> Enum.map(fn n ->
        1..2000
        |> Enum.reduce([n], fn _, n ->
          [generate_secret_number(hd(n)) | n]
        end)
      end)
      |> Enum.map(fn sequence ->
        sequence
        |> Enum.map(fn n ->
          rem(n, 10)
        end)
        |> Enum.reverse()
      end)

    bananas =
      sequences
      |> Enum.reduce(%{}, fn sequence, bananas ->
        {bananas, _} =
          sequence
          |> Enum.chunk_every(5, 1, :discard)
          |> Enum.reduce({bananas, MapSet.new()}, fn [a, b, c, d, e], {bananas, seen} ->
            key = {b - a, c - b, d - c, e - d}

            if not MapSet.member?(seen, key) do
              {
                Map.update(bananas, key, e, &(&1 + e)),
                MapSet.put(seen, key)
              }
            else
              {bananas, seen}
            end
          end)

        bananas
      end)

    bananas
    |> Map.values()
    |> Enum.max()
  end
end
