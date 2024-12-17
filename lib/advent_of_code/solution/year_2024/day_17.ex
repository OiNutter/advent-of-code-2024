defmodule AdventOfCode.Solution.Year2024.Day17 do
  def get_combo_operand(operand, registers) do
    case operand do
      4 -> Map.fetch!(registers, :A)
      5 -> Map.fetch!(registers, :B)
      6 -> Map.fetch!(registers, :C)
      7 -> :noop
      _ -> operand
    end
  end

  def do_instruction(instruction, operand, registers, output) do
    case instruction do
      0 ->
        {Map.update!(
           registers,
           :A,
           &trunc(&1 / Integer.pow(2, get_combo_operand(operand, registers)))
         ), output}

      1 ->
        {Map.update!(registers, :B, &Bitwise.bxor(&1, operand)), output}

      2 ->
        {Map.update!(registers, :B, fn _ -> rem(get_combo_operand(operand, registers), 8) end),
         output}

      4 ->
        {Map.update!(registers, :B, &Bitwise.bxor(&1, Map.fetch!(registers, :C))), output}

      5 ->
        {registers, [rem(get_combo_operand(operand, registers), 8) | output]}

      6 ->
        {Map.update!(registers, :B, fn _ ->
           trunc(
             Map.fetch!(registers, :A) / Integer.pow(2, get_combo_operand(operand, registers))
           )
         end), output}

      7 ->
        {Map.update!(registers, :C, fn _ ->
           trunc(
             Map.fetch!(registers, :A) / Integer.pow(2, get_combo_operand(operand, registers))
           )
         end), output}
    end
  end

  def run_program(instructions, operands, registers, pointer, output) do
    if pointer >= length(instructions) do
      output
    else
      instruction = instructions |> Enum.at(pointer)
      operand = operands |> Enum.at(pointer)

      if instruction === 3 do
        if Map.fetch!(registers, :A) !== 0 do
          # IO.inspect(operand)
          run_program(instructions, operands, registers, operand, output)
        else
          run_program(instructions, operands, registers, pointer + 1, output)
        end
      else
        # IO.inspect({instruction, operand, registers})
        {registers, output} = do_instruction(instruction, operand, registers, output)
        # IO.inspect({registers, output})
        run_program(instructions, operands, registers, pointer + 1, output)
      end
    end
  end

  def parse_registers(registers) do
    registers
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, ": "))
    |> Enum.map(fn [name, value] ->
      {String.to_atom(String.replace(name, "Register ", "")), String.to_integer(value)}
    end)
    |> Enum.into(%{})
  end

  def parse_program(program) do
    {instructions, operands} =
      program
      |> String.replace("Program: ", "")
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()
      |> Enum.split_with(fn {_, i} -> rem(i, 2) === 0 end)

    {instructions |> Enum.map(fn {v, _} -> v end), operands |> Enum.map(fn {v, _} -> v end)}
  end

  def parse(input) do
    [registers, program] =
      input
      |> String.trim()
      |> String.split("\n\n", trim: true)

    {parse_registers(registers), parse_program(program)}
  end

  def part1(input) do
    {registers, {instructions, operands}} = parse(input)

    run_program(instructions, operands, registers, 0, [])
    |> Enum.reverse()
    |> Enum.join(",")
  end

  def part2(input) do
    [registers, original_program] =
      input
      |> String.trim()
      |> String.split("\n\n", trim: true)

    registers = parse_registers(registers)
    {instructions, operands} = parse_program(original_program)

    expected = String.replace(original_program, "Program: ", "") |> String.split(",", trim: true) |> Enum.map(&String.to_integer/1) |> Enum.reverse()

    {valid, _} = 0..length(expected)-1
    |> Enum.reduce({[], 0..7 |> Range.to_list()}, fn i, {_, queue} ->
      valid = queue
      |> Enum.reduce([], fn n, valid ->
        output = run_program(instructions, operands, Map.put(registers, :A, n), 0, [])
        if not Enum.empty?(output) and length(output) === i+1 and output === Enum.take(expected, i+1) do
          [n | valid]
        else
          valid
        end
      end)

      queue = Enum.reduce(valid, [], fn n, next ->
        0..7
        |> Enum.reduce(next, fn j, next ->
          [(n * 8) + j | next]
        end)
      end)

      {valid, queue}

    end)

    valid
    |> Enum.min()

  end
end
