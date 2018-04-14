defmodule MapDiff do
  def diff(map_a, map_b) when is_map(map_a) and is_map(map_b) do
    changes_and_additions =
      find_changes_and_additions(map_a, map_b, [], %{:added => %{}, :changed => %{}})

    find_deletions(map_b, map_a, [], Map.put(changes_and_additions, :deleted, %{}))
  end

  defp find_deletions(map_a, map_b, key_path, result) when is_map(map_a) and is_map(map_b) do
    map_b
    |> Map.keys()
    |> Enum.reduce(result, fn k, acc ->
      map_a_value = Map.get(map_a, k)
      %{^k => map_b_value} = map_b
      new_key_path = [k | key_path]

      do_find_deletions(map_a_value, map_b_value, new_key_path, acc)
    end)
  end

  defp find_deletions(_, _, _, acc), do: acc

  defp do_find_deletions(nil, map_b_value, new_key_path, acc) do
    reversed_new_key_path = new_key_path |> Enum.reverse()
    Map.update!(acc, :deleted, &Map.put(&1, reversed_new_key_path, map_b_value))
  end

  defp do_find_deletions(map_a_value, map_b_value, new_key_path, acc) do
    find_deletions(map_a_value, map_b_value, new_key_path, acc)
  end

  defp find_changes_and_additions(map_a, map_b, key_path, result)
       when is_map(map_a) and is_map(map_b) do
    map_b
    |> Map.keys()
    |> Enum.reduce(result, fn k, acc ->
      map_a_value = Map.get(map_a, k)
      %{^k => map_b_value} = map_b
      new_key_path = [k | key_path]

      do_find_changes_and_additions(map_a_value, map_b_value, new_key_path, acc)
    end)
  end

  defp find_changes_and_additions(map_a_value, map_b_value, new_key_path, acc)
       when map_a_value != map_b_value do
    reversed_new_key_path = new_key_path |> Enum.reverse()
    Map.update!(acc, :changed, &Map.put(&1, reversed_new_key_path, map_b_value))
  end

  defp find_changes_and_additions(_, _, _, acc), do: acc

  defp do_find_changes_and_additions(nil, map_b_value, new_key_path, acc) do
    reversed_new_key_path = new_key_path |> Enum.reverse()
    Map.update!(acc, :added, &Map.put(&1, reversed_new_key_path, map_b_value))
  end

  defp do_find_changes_and_additions(map_a_value, map_b_value, new_key_path, acc) do
    find_changes_and_additions(map_a_value, map_b_value, new_key_path, acc)
  end
end
