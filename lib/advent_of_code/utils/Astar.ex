defmodule Astar do
  def astar(env, start, goal) do
    {nbs, dist, h} = env
    open_set = :gb_sets.singleton({h.(start), start})
    came_from = %{}
    g_score = %{start => 0}
    f_score = %{start => h.(start)}

    astar_loop(open_set, came_from, g_score, f_score, nbs, dist, h, goal)
  end

  defp astar_loop(open_set, came_from, g_score, f_score, nbs, dist, h, goal) do
    if :gb_sets.is_empty(open_set) do
      :no_path
    else
      {{_, current}, open_set} = :gb_sets.take_smallest(open_set)

      if goal.(current) do
        reconstruct_path(came_from, current)
      else
        neighbors = nbs.(current)

        {open_set, came_from, g_score, f_score} =
          Enum.reduce(neighbors, {open_set, came_from, g_score, f_score}, fn neighbor, {open_set, came_from, g_score, f_score} ->
            tentative_g_score = Map.get(g_score, current, :infinity) + dist.(current, neighbor)

            if tentative_g_score < Map.get(g_score, neighbor, :infinity) do
              came_from = Map.put(came_from, neighbor, current)
              g_score = Map.put(g_score, neighbor, tentative_g_score)
              f_score = Map.put(f_score, neighbor, tentative_g_score + h.(neighbor))

              open_set = if not :gb_sets.is_member({f_score[neighbor], neighbor}, open_set) do
                :gb_sets.add({f_score[neighbor], neighbor}, open_set)
              else
                open_set
              end

              {open_set, came_from, g_score, f_score}
            else
              {open_set, came_from, g_score, f_score}
            end
          end)

        astar_loop(open_set, came_from, g_score, f_score, nbs, dist, h, goal)
      end
    end
  end

  defp reconstruct_path(came_from, current) do
    reconstruct_path(came_from, current, [current])
  end

  defp reconstruct_path(came_from, current, path) do
    case Map.get(came_from, current) do
      nil -> Enum.reverse(path)
      parent -> reconstruct_path(came_from, parent, [parent | path])
    end
  end
end
