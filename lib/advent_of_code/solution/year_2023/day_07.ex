defmodule AdventOfCode.Solution.Year2023.Day07 do

  use AdventOfCode.Solution.SharedParse

  @card_scores %{
    :A => 14,
    :K => 13,
    :Q => 12,
    :J => 11,
    :T => 10
  }

  @hand_scores %{
    :five_of_a_kind => 700,
    :four_of_a_kind => 600,
    :full_house => 500,
    :three_of_a_kind => 400,
    :two_pair => 300,
    :one_pair => 200,
    :high_card => 100
  }

  def get_hand_result(cards, wildcard \\ false) do
    card_counts = cards
    |> Enum.reduce(%{}, fn card, counts ->
      Map.update(counts, card, 1, &(&1+1))
    end)

    get_hand_type(card_counts, wildcard)
  end

  def get_card_score(card, wildcard \\ false) do
    if wildcard and card === :J do
      1
    else
     score = Map.get(@card_scores, card)

     if score, do: score, else: card
    end
  end

  defp get_hand_type(card_counts, wildcard) do
    counts = Map.values(card_counts)
    max_count = Enum.max(counts)

    {counts, max_count, _} = if max_count !== 5 and wildcard do
      cards = Map.to_list(card_counts)
      |> Enum.filter(fn {_, count} -> count === max_count end)

      {counts, max_count, card_counts} = if not (length(cards) === 1 and elem(hd(cards), 0) === :J) do
        max_count = max_count + Map.get(card_counts, :J, 0)
        card = elem(hd(cards), 0)

        card_counts = Map.update!(card_counts, card, &(&1 + Map.get(card_counts, :J, 0)))
        |> Map.put(:J, 0)
        counts = Map.values(card_counts)
        {counts, max_count, card_counts}
      else
        # J is max count so add to next highest score

          next_highest = Map.to_list(card_counts)
          |> Enum.filter( fn {card, _} ->
            card !== :J
          end)
          |> Enum.sort(fn {_,a}, {_,b}  ->
            if a < b do
              true
            else
              false
            end
          end)
          |> hd()

          max_count = max_count + elem(next_highest, 1)
          card_counts = Map.put(card_counts, :J, max_count)
          |> Map.put(elem(next_highest,0), 0)
          counts = Map.values(card_counts)
          {counts, max_count, card_counts}
      end
      {counts, max_count, card_counts}
    else
      {counts, max_count, card_counts}
    end

    case max_count do
      5 -> @hand_scores[:five_of_a_kind]
      4 -> @hand_scores[:four_of_a_kind]
      3 ->
        if Enum.any?(counts, fn x -> x === 2 end) do
          @hand_scores[:full_house]
        else
          @hand_scores[:three_of_a_kind]
        end
      2 ->
        if Enum.count(counts, fn x -> x === 2 end) === 2 do
          @hand_scores[:two_pair]
        else
          @hand_scores[:one_pair]
        end
      _ -> @hand_scores[:high_card]
    end
  end

  def rank_hands(hands, wildcard \\ false) do
    hands
    |> Enum.map(fn hand ->
      %{
        :cards => hand.cards,
        :score => get_hand_result(hand.cards, wildcard),
      }
    end)
    |> Enum.sort(fn a, b ->
      cond do
        a.score < b.score ->
          true

        b.score < a.score ->
          false

        true ->
          a.cards
          |> Enum.zip(b.cards)
          |> Enum.reduce_while(0, fn {a_card, b_card}, _ ->
            a_score = get_card_score(a_card, wildcard)
            b_score = get_card_score(b_card, wildcard)

            cond do
              a_score < b_score ->
                {:halt, true}

              a_score > b_score ->
                {:halt, false}

              true ->
                {:cont, 0}
            end
          end)
      end
    end)
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [cards, bet] = String.split(line, ~r/\s+/, trim: true, parts: 2)

      {cards,
        %{
          :cards => String.split(cards, "", trim: true) |> Enum.map(fn char -> try do String.to_integer(char) rescue _ -> String.to_atom(char) end end),
          :bet => String.to_integer(bet)
        }}
    end)
    |> Map.new()
  end

  def part1(hands) do

    hands
    |> Map.values()
    |> rank_hands()
    |> Enum.with_index()
    |> Enum.reduce(0, fn {result, i}, pot ->
        bet = Map.get(hands, result.cards |> Enum.join("")).bet
        pot + (bet * (i+1))
    end)
  end

  def part2(hands) do
    hands
    |> Map.values()
    |> rank_hands(true)
    |> Enum.with_index()
    |> Enum.reduce(0, fn {result, i}, pot ->
        bet = Map.get(hands, result.cards |> Enum.join("")).bet
        pot + (bet * (i+1))
    end)
  end
end
