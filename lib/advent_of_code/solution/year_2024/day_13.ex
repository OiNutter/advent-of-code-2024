defmodule AdventOfCode.Solution.Year2024.Day13 do
  def parse_coords(line) do
    %{"x" => x, "y" => y} =
      Regex.named_captures(~r/X(\+|\=)(?<x>[0-9]+), Y(\+|\=)(?<y>[0-9]+)/, line)

    {String.to_integer(x), String.to_integer(y)}
  end

  def parse_machine(machine, multiply \\ false) do
    [button_a, button_b, prize] =
      machine
      |> String.split("\n", trim: true, parts: 3)

    {prize_x, prize_y} = parse_coords(prize)

    prize_x = if multiply, do: prize_x + 10000000000000, else: prize_x
    prize_y = if multiply, do: prize_y + 10000000000000, else: prize_y
    %{
      a: parse_coords(button_a),
      b: parse_coords(button_b),
      prize: {prize_x, prize_y}
    }
  end

  def parse_machines(input, multiply \\ false) do

    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn line -> parse_machine(line, multiply) end)

  end

  def test_case(n, machine) do
    {a_x, a_y} = machine.a
    {b_x, b_y} = machine.b

    new_x = b_x * n
    new_y = b_y * n

    {prize_x, prize_y} = machine.prize

    IO.inspect("===")
    IO.inspect({new_x, new_y})
    IO.inspect(machine.prize)

    if {new_x, new_y} === machine.prize do
      n
    else
      if new_x <= prize_x && new_y <= prize_y do
        diff_x = prize_x - new_x
        diff_y = prize_y - new_y

        if rem(diff_x, a_x) == 0 && rem(diff_y, a_y) == 0 do
          if diff_x / a_x == diff_y / a_y do
            3 * (diff_x/a_x) + n
          else
            test_case(n+1, machine)
          end
        else
          test_case(n+1, machine)
        end
      else
        test_case(n+1, machine)
      end
    end
  end

  @spec solve([{number(), number()}, ...]) :: nil | [integer(), ...]
  def solve([{a_x, a_y}, {b_x, b_y}, {p_x, p_y}]) do
    x = ((b_y * p_x) - (b_x * p_y)) / ((a_x * b_y) - (b_x * a_y))
    y = ((a_x * p_y) - (a_y * p_x)) / ((a_x * b_y) - (b_x * a_y))
    if floor(x) == x and floor(y) == y do
      [trunc(x), trunc(y)]
    end
  end

  def calc1?([a,b]) when a <= 100 and b <= 100, do: [3*a + b]
  def calc1?(_), do: []

  def calc2?([a,b]), do: [3*a + b]
  def calc2?(_), do: []

  def part1(input) do
    machines = parse_machines(input)

    machines
    |> Enum.map(fn machine ->
      solve([machine.a, machine.b, machine.prize])
    end)
    |> Enum.flat_map(&calc1?/1)
    |> Enum.sum()

    # machines
    # |> Enum.map(fn machine ->
    #   Enum.reduce(0..100, [:infinity], fn n, costs ->
    #     {a_x, a_y} = machine.a
    #     {b_x, b_y} = machine.b

    #     new_x = a_x * n
    #     new_y = a_y * n

    #     {prize_x, prize_y} = machine.prize

    #     if {new_x, new_y} === machine.prize do
    #       [3 * n | costs]
    #     else
    #       if new_x <= prize_x && new_y <= prize_y do
    #         diff_x = prize_x - new_x
    #         diff_y = prize_y - new_y

    #         if rem(diff_x, b_x) == 0 && rem(diff_y, b_y) == 0 do
    #           if diff_x / b_x == diff_y / b_y do
    #             [3 * n + diff_x / b_x | costs]
    #           else
    #             costs
    #           end
    #         else
    #           costs
    #         end
    #       else
    #         costs
    #       end
    #     end
    #   end)
    #   |> Enum.min()
    # end)
    # |> Enum.filter(fn n -> n !== :infinity end)
    # |> Enum.sum()
    # |> trunc()
  end

  def part2(input) do
    machines = parse_machines(input, true)

    machines
    |> Enum.map(fn machine ->
      solve([machine.a, machine.b, machine.prize])
    end)
    |> Enum.flat_map(&calc2?/1)
    |> Enum.sum()
  end
end
