defmodule Dijkstra do
  def dijkstra(start, goal, neighbors_fn, cost_fn) do
    dijkstra([{0, start}], goal, neighbors_fn, cost_fn, %{}, %{})
  end

  defp dijkstra([], _goal, _neighbors_fn, _cost_fn, _distances, _parents), do: :no_path

  defp dijkstra([{current_cost, current} | rest], goal, neighbors_fn, cost_fn, distances, parents) do
    if current == goal do
      build_path(goal, parents)
    else
      neighbors = neighbors_fn.(current)
      {new_distances, new_parents, new_queue} =
        Enum.reduce(neighbors, {distances, parents, rest}, fn neighbor, {dist_acc, parents_acc, queue_acc} ->
          new_cost = current_cost + cost_fn.(current, neighbor)
          if Map.get(dist_acc, neighbor, :infinity) > new_cost do
            {
              Map.put(dist_acc, neighbor, new_cost),
              Map.put(parents_acc, neighbor, current),
              [{new_cost, neighbor} | queue_acc]
            }
          else
            {dist_acc, parents_acc, queue_acc}
          end
        end)

      sorted_queue = Enum.sort_by(new_queue, fn {cost, _} -> cost end)
      dijkstra(sorted_queue, goal, neighbors_fn, cost_fn, new_distances, new_parents)
    end
  end

  defp build_path(goal, parents) do
    build_path(goal, parents, [])
  end

  defp build_path(nil, _parents, path), do: Enum.reverse(path)

  defp build_path(current, parents, path) do
    build_path(Map.get(parents, current), parents, [current | path])
  end
end
