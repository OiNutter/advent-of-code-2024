defmodule AdventOfCode.Solution.Year2024.Day24 do
  use AdventOfCode.Solution.SharedParse

  @spec solve(nonempty_maybe_improper_list(), any()) :: nil
  def solve([], wires), do: wires

  def solve([{a, b, op, c} | rest], wires) do
    if Map.has_key?(wires, a) and Map.has_key?(wires, b) do
      val_a = Map.get(wires, a)
      val_b = Map.get(wires, b)

      wires =
        case op do
          :AND -> Map.put(wires, c, val_a && val_b)
          :OR -> Map.put(wires, c, val_a || val_b)
          :XOR -> Map.put(wires, c, val_a != val_b)
        end

      solve(rest, wires)
    else
      solve(rest ++ [{a, b, op, c}], wires)
    end
  end

  def parse(input) do
    [wires, gates] = input |> String.split("\n\n", trim: true, parts: 2)

    {
      wires
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        <<a::binary-size(3), ": ", b::binary-size(1)>> = line

        a = String.to_atom(a)
        b = String.to_integer(b)
        {a, b === 1}
      end)
      |> Map.new(),
      gates
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        [a, op, b, _, c] = String.split(line, " ", trim: true, parts: 5)

        a = String.to_atom(a)
        op = String.to_atom(op)
        b = String.to_atom(b)
        c = String.to_atom(c)
        {a, b, op, c}
      end)
    }
  end
  def part1({wires, gates}) do
    solve(gates, wires)
    |> Enum.filter(fn {k, _} -> Atom.to_string(k) |> String.starts_with?("z") end)
    |> Enum.sort(:desc)
    |> Enum.map(fn {_, v} -> if v, do: 1, else: 0 end)
    |> Enum.join("")
    |> Integer.parse(2)
    |> elem(0)
  end

  def part2({wires, gates}) do

    max_length = wires |> Enum.filter(fn {k, _} -> Atom.to_string(k) |> String.starts_with?("x") end) |> length()

   issues = gates
   |> Enum.reduce(MapSet.new(), fn {a,b,op,c}, acc ->

    acc = if op === :XOR and (String.starts_with?(Atom.to_string(a), "x") or String.starts_with?(Atom.to_string(b), "x")) do
      if a === :x00 or b === :x00 do
        if c !== :z00, do: MapSet.put(acc, c), else: acc
      else
        if String.starts_with?(Atom.to_string(c), "z"), do: MapSet.put(acc, c), else: acc
      end
    else
      acc
    end

    acc = if op === :XOR and not String.starts_with?(Atom.to_string(a), "x") and not String.starts_with?(Atom.to_string(b), "x") and !String.starts_with?(Atom.to_string(c), "z") do
      MapSet.put(acc, c)
    else
      acc
    end

    acc = if String.starts_with?(Atom.to_string(c), "z") do
      if c === String.to_atom("z" <> String.pad_leading(Integer.to_string(max_length), 2, "0")) do
        if op !== :OR do
          MapSet.put(acc, c)
        else
          acc
        end
      else
        if op !== :XOR do
          MapSet.put(acc, c)
        else
          acc
        end
      end
    else
      acc
    end
    acc
   end)

   {issues, to_check} = gates
   |> Enum.reduce({issues, []}, fn {a,b,op,c}, {issues, to_check} ->
    if op === :XOR and (String.starts_with?(Atom.to_string(a), "x") or String.starts_with?(Atom.to_string(b), "x")) do
      if MapSet.member?(issues, c) do
        {issues, to_check}
      else
        if c === :z00 do
          {issues, to_check}
        else
          m = gates
          |> Enum.filter(fn {a,b,op,_} -> op === :XOR and !String.starts_with?(Atom.to_string(a), "x") and !String.starts_with?(Atom.to_string(b), "x") end)
          |> Enum.filter(fn {a,b,_,_} -> a === c || b === c end)
          |> length()

          if m === 0 do
            {MapSet.put(issues, c), [{a,b,op,c} | to_check]}
          else
            {issues, to_check}
          end
        end
      end
    else
      {issues, to_check}
    end
   end)

   to_check
   |> Enum.reverse()
   |> Enum.reduce(issues, fn gate, acc ->
      m = gates
      |> Enum.filter(fn {a,b,op,_} -> op === :XOR and !String.starts_with?(Atom.to_string(a), "x") and !String.starts_with?(Atom.to_string(b), "x") end)
      |> Enum.filter(fn {_,_,_,c} -> c === String.to_atom("z" <> String.slice(Atom.to_string(elem(gate, 0)), 1, 2)) end)

      m = hd(m)

      or_matches = gates
      |> Enum.filter(fn {_,_,op,_} -> op === :OR end)
      |> Enum.filter(fn {_,_,_,c} -> elem(m,0) === c || elem(m,1) === c end)

      {_, _,_, or_match_output} = hd(or_matches)

      acc = cond do
        elem(m, 0) != or_match_output ->
          MapSet.put(acc, elem(m,0))
        elem(m,1) != or_match_output ->
          MapSet.put(acc, elem(m,1))
      end

      acc
   end)
   |> Enum.sort()
   |> Enum.join(",")
  end
end
