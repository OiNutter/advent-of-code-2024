defmodule AdventOfCode.Solution.Year2024.Day09 do

  def annotate([], _), do: []
  def annotate([first|remainder], id) when id >= 0, do: [{id, first} | annotate(remainder, -id-1)]
  def annotate([first|remainder], id), do: [first | annotate(remainder, -id)]

  def fill_gaps([], _, _), do: []
  def fill_gaps(_, _, runs) when runs <= 0, do: []
  def fill_gaps([{x, n} | remainder], reversed, runs), do: [{x, n} | fill_gaps(remainder, reversed, runs-n)]
  def fill_gaps([gap | remainder], [{y, m} | reversed], runs) do
    gap = min(gap, runs)
    cond do
      gap == 0 -> fill_gaps(remainder, [{y, m} | reversed], runs)
      gap  > m -> [{y, m} | fill_gaps([gap - m | remainder], reversed, runs-m)]
      gap == m -> [{y, m} | fill_gaps(remainder, reversed, runs-m)]
      true     -> [{y, gap} | fill_gaps(remainder, [{y, m - gap} | reversed], runs - gap)]
    end
  end
  def fill_gaps(remainder, [_gap | reversed], runs), do: fill_gaps(remainder, reversed, runs)

  def take(_, 0), do: []
  def take([{id, m} | rest], n), do: if(m < n, do: [{id, m} | take(rest, n-m)], else: [{id, n}])

  def checksum([], _), do: []
  def checksum([{id, 1} | ids], n), do: [n * id | checksum(ids, n+1)]
  def checksum([{id, k} | ids], n), do: [n * id | checksum([{id, k-1} | ids], n+1)]

  def enumerate_gaps([], gaps, blocks, _), do: {gaps, blocks}
  def enumerate_gaps([{_, k} = block| rle], gaps, blocks, i), do: enumerate_gaps(rle, gaps, [{i, block} | blocks], i+k)
  def enumerate_gaps([0 | rle], gaps, blocks, i), do: enumerate_gaps(rle, gaps, blocks, i)
  def enumerate_gaps([gap | rle], gaps, blocks, i), do: enumerate_gaps(rle, [{gap, i} | gaps], blocks, i+gap)

  def fill_blocks(_, []), do: []
  def fill_blocks(gaps, [{i, {id, k}} = block | blocks]) do
    candidate = Enum.find_index(gaps, fn {g, j} -> g >= k && j < i end)
    if candidate do
      {gap, index} = Enum.at(gaps, candidate)
      updated = if gap == k do
        List.delete_at(gaps, candidate)
      else
        List.replace_at(gaps, candidate, {gap - k, index + k})
      end
      [{index, {id, k}} | fill_blocks(updated, blocks)]
    else
      [block | fill_blocks(gaps, blocks)]
    end
  end

  def checksum_blocks([]), do: 0
  def checksum_blocks([{i, {id, 1}} | blocks]), do: i * id + checksum_blocks(blocks)
  def checksum_blocks([{i, {id, block_length}} | blocks]), do: i * id + checksum_blocks([{i+1, {id, block_length-1}} | blocks])

  def parse_input(input) do
    input
    |> String.trim_trailing()
    |> String.split("", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> annotate(0)
  end



  def part1(input) do
    disk_map = parse_input(input)
    total_runs = disk_map |> Enum.filter(&is_tuple/1) |> Enum.map(&elem(&1, 1)) |> Enum.sum

    fill_gaps(disk_map, Enum.reverse(disk_map), total_runs)
    |> take(total_runs)
    |> checksum(0)
    |> Enum.sum()
  end

  def part2(input) do

    disk_map = parse_input(input)
    { gaps, blocks} = enumerate_gaps(disk_map, [], [], 0)
    fill_blocks(Enum.reverse(gaps), blocks)
    |> checksum_blocks()
  end
end
