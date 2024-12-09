defmodule AdventOfCode.Solution.Year2024.Day09 do
  def move_files(disk_map) do
    file_to_move =
      disk_map
      |> Enum.reverse()
      |> Enum.find_index(fn block -> block !== "." end)

    first_space =
      disk_map
      |> Enum.find_index(fn block -> block === "." end)

    if file_to_move === nil || first_space === nil do
      disk_map
    else
      real_index = length(disk_map) - 1 - file_to_move

      if real_index < first_space do
        disk_map
      else
        move_files(
          disk_map
          |> List.replace_at(first_space, Enum.at(disk_map, real_index))
          |> List.replace_at(real_index, ".")
        )
      end
    end
  end

  def move_whole_files(disk_map, highest_index) do
    if highest_index < 0 do
      disk_map
    else
      file = Map.get(disk_map, highest_index)
      file_length = length(file)

      # find free space
      free_block =
        Map.get(disk_map, ".")
        |> Enum.reduce_while([], fn index, spaces ->

          if length(spaces) === file_length do
            {:halt, spaces}
          else

            last = List.last(spaces)

            if last do
              if index === last + 1 do
                if length(spaces) + 1 === file_length do
                  {:halt, spaces ++ [index]}
                else
                  {:cont, spaces ++ [index]}
                end
              else
                {:cont, [index]}
              end
            else
              {:cont, [index]}
            end
          end
        end)

      if length(free_block) === file_length && List.first(file) > List.first(free_block) do
        move_whole_files(
          disk_map
          |> Map.put(highest_index, free_block)
          |> Map.update!(".", fn current ->
            (free_block
             |> Enum.reduce(current, fn index, current -> List.delete(current, index) end)) ++
              file
          end),
          highest_index - 1
        )
      else
        move_whole_files(disk_map, highest_index - 1)
      end
    end
  end

  def part1(input) do
    {disk_map, _} =
      input
      |> String.split("", trim: true)
      |> Enum.with_index()
      |> Enum.reduce({[], 0}, fn {block, i}, {disk, id} ->
        block_length = String.to_integer(block)

        new_blocks =
          if block_length > 0,
            do:
              Enum.map(0..(block_length - 1), fn _ ->
                if rem(i, 2) === 0, do: id, else: "."
              end),
            else: []

        new_id = if rem(i, 2) === 0, do: id + 1, else: id
        {disk ++ new_blocks, new_id}
      end)

    move_files(disk_map)
    |> Enum.with_index()
    |> Enum.map(fn {file, i} ->
      if file === ".", do: 0, else: file * i
    end)
    |> Enum.sum()
  end

  def part2(input) do
    {disk, highest_index} =
      input
      |> String.split("", trim: true)
      |> Enum.with_index()
      |> Enum.reduce({[], 0}, fn {block, i}, {disk, id} ->
        block_length = String.to_integer(block)

        new_blocks =
          if block_length > 0,
            do:
              Enum.map(0..(block_length - 1), fn _ ->
                if rem(i, 2) === 0, do: id, else: "."
              end),
            else: []

        new_id = if rem(i, 2) === 0, do: id + 1, else: id
        {disk ++ new_blocks, new_id}
      end)

    disk_map =
      disk
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {block, i}, disk_map ->
        disk_map
        |> Map.update(block, [], & &1)
        |> Map.update(block, [], &(&1 ++ [i]))
      end)

    move_whole_files(disk_map, highest_index - 1)
    |> Enum.reduce(disk, fn {id, positions}, disk ->
      Enum.reduce(positions, disk, fn position, disk ->
        List.replace_at(disk, position, id)
      end)
    end)
    |> Enum.with_index()
    |> Enum.map(fn {file, i} ->
      if file === ".", do: 0, else: file * i
    end)
    |> Enum.sum()
  end
end
