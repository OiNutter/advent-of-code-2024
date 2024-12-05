defmodule AdventOfCode.Solution.Year2024.Day04 do
   def get_xmas_regex(dist) do
    {_, regex} = Regex.compile("(?=(X.{#{dist}}M.{#{dist}}A.{#{dist}}S))")
    regex
  end

  def count_forward(string, line_length) do
    [
      get_xmas_regex(0)
      |> Regex.scan(string)
      |> length(),
      get_xmas_regex(line_length)
      |> Regex.scan(string)
      |> length(),
      get_xmas_regex(line_length+1)
      |> Regex.scan(string)
      |> length(),
      get_xmas_regex(line_length-1)
      |> Regex.scan(string)
      |> length()
    ]
    |> Enum.sum()
  end

  def part1(input) do
    line_length = input
      |> String.split("\n", trim: true)
      |> List.first()
      |> String.length()
    parsed = input
    |> String.replace("\n", ".")

    reversed = parsed
    |> String.split("", trim: true)
    |> Enum.reverse()
    |> Enum.join("")

    count_forward(parsed, line_length) + count_forward(reversed, line_length)
  end

  def part2(input) do
    grid = input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      String.split(line, "", trim: true)
    end)

    grid
    |> Enum.with_index()
    |> Enum.reduce(0, fn {line, y}, count ->
      line
      |> Enum.with_index()
      |> Enum.reduce(count, fn {char, x}, count ->
        if char === "M" || char === "S" do
          bottom_right_search = if char === "M", do: "S", else: "M"
          # check top right corner
          if Enum.at(line, x+2) === "M" || Enum.at(line, x+2) === "S" do
            bottom_left_search = if Enum.at(line, x+2) === "M", do: "S", else: "M"
            # check bottom left corner
            if Enum.at(Enum.at(grid, y+2, []), x) === bottom_left_search do
              # check bottom right corner
              if Enum.at(Enum.at(grid, y+2,[]), x+2) === bottom_right_search do
                # check middle
                if Enum.at(Enum.at(grid, y+1,[]), x+1) === "A" do
                  count + 1
                else
                  count
                end
              else
                count
              end
            else
              count
            end
          else
            count
          end
        else
          count
        end
      end)
    end)
  end
end
