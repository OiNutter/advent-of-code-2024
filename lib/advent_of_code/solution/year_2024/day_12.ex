defmodule AdventOfCode.Solution.Year2024.Day12 do

  use AdventOfCode.Solution.SharedParse

  def calculate_perimeter([]), do: 0
  def calculate_perimeter(region) when length(region) === 1, do: 4

  def calculate_perimeter(region) do
    region
    |> Enum.reduce(0, fn {x, y}, sides ->
      found_sides = 0

      # top side
      found_sides = if !Enum.member?(region, {x, y - 1}), do: found_sides + 1, else: found_sides

      # bottom side
      found_sides = if !Enum.member?(region, {x, y + 1}), do: found_sides + 1, else: found_sides

      # left side
      found_sides = if !Enum.member?(region, {x - 1, y}), do: found_sides + 1, else: found_sides

      # right side
      found_sides = if !Enum.member?(region, {x + 1, y}), do: found_sides + 1, else: found_sides

      sides + found_sides
    end)
  end

  def build_region({x, y}, char, map, squares) do

    if !Map.get(map, {x, y}) || Map.get(map, {x, y}) !== char || Enum.member?(squares, {x, y}) do
      squares
    else
      Enum.reduce(-1..1, squares, fn dx, squares ->
        Enum.reduce(-1..1, squares, fn dy, squares ->
          if dx === dy do
            squares
          else
            # IO.inspect({dx, dy})
            new_x = x + dx
            new_y = y + dy

            MapSet.new(squares ++ build_region({new_x, new_y}, char, map, [{x, y} | squares]))
            |> MapSet.to_list()
          end
        end)
      end)

    end
  end

  defp group_connecting(coords),
    do: do_group_connecting([hd(coords)], tl(coords), [MapSet.new()])

  defp do_group_connecting([], [], list), do: list

  defp do_group_connecting([], coords, list) do
    do_group_connecting([hd(coords)], tl(coords), [MapSet.new() | list])
  end

  defp do_group_connecting([{row, col} | coords], rest, list) do
    {adjacent, not_adjacent} =
      Enum.split_with(rest, fn rest ->
        Enum.any?([{0, -1}, {0, 1}, {-1, 0}, {1, 0}], fn {offset_row, offset_col} ->
          rest == {row + offset_row, col + offset_col}
        end)
      end)

    do_group_connecting(adjacent ++ coords, not_adjacent, [
      MapSet.put(hd(list), {row, col}) | tl(list)
    ])
  end

  def find_regions(grid) do
    grid
    |> Enum.group_by(fn {_coord, plot} -> plot end)
    |> Task.async_stream(fn {plot, list} ->
      coords = Enum.map(list, fn {coord, _plot} -> coord end)

      {plot,
       group_connecting(coords)
       |> Enum.map(fn coords -> %{coords: coords} end)}
    end)
    |> Enum.reduce(%{}, fn {:ok, {plot, regions}}, acc -> Map.put(acc, plot, regions) end)
  end

  def find_borders(regions, grid) do
    regions
    |> Enum.map(fn {plot, plot_regions} ->
      {plot,
       Enum.map(plot_regions, fn plot_region ->
         borders =
           Enum.reduce(plot_region.coords, MapSet.new(), fn coord, acc ->
             grid
             |> find_new_borders(coord, plot)
             |> Enum.reduce(acc, fn coord, acc -> MapSet.put(acc, coord) end)
           end)

         Map.put(plot_region, :borders, borders)
       end)}
    end)
    |> Map.new()
  end

  defp find_new_borders(map, {row, col}, plot) do
    [
      {{0, -1}, :left},
      {{0, 1}, :right},
      {{-1, 0}, :up},
      {{1, 0}, :down}
    ]
    |> Enum.filter(fn {{offset_row, offset_col}, _} ->
      Map.get(map, {row + offset_row, col + offset_col}) != plot
    end)
    |> Enum.map(fn {{offset_row, offset_col}, dir} ->
      {{row + offset_row, col + offset_col}, dir}
    end)
  end

  def parse_map(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, y}, map ->
      line
      |> String.split("", trim: true)
      |> Enum.with_index()
      |> Enum.reduce(map, fn {char, x}, map ->
        Map.put(map, {x, y}, char)
      end)
    end)
  end

  def parse(input) do
    map = input
    |> parse_map()

    map
    |> find_regions()
    |> find_borders(map)
  end

  def part1(map) do
    map
    |> Enum.reduce([], fn {_, v}, regions -> regions ++ v end)
    |> Enum.reduce(0, fn region, cost ->
      cost + MapSet.size(region.coords) * MapSet.size(region.borders)
    end)
  end

  def part2(map) do
    map
    |> Task.async_stream(fn {plot, regions} ->
        {
          plot,
          Enum.map(regions, fn region ->
            sides = region.borders
            |> Enum.group_by(fn {_, dir} -> dir end)
            |> Enum.flat_map(fn {_, list} ->
              list
              |> Enum.map(fn {coord, _} -> coord  end)
              |> group_connecting()

            end)
            Map.put(region, :sides, sides)
          end)
        }
    end)
    |> Enum.reduce(%{}, fn {:ok, {plot, regions}}, acc -> Map.put(acc, plot, regions) end)
    |> Enum.reduce([], fn {_, v}, regions -> regions ++ v end)
    |> Enum.reduce(0, fn region, cost ->
      cost + MapSet.size(region.coords) * length(region.sides)
    end)
  end
end
