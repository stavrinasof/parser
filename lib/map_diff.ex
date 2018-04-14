defmodule MapDiff do

  def diff(map_a, map_b) when is_map(map_a) and is_map(map_b) do
    result = diffs(map_a, map_b, [], %{:added => %{}, :changes => %{}})
    diffs2(map_b, map_a, [], Map.put(result, :deleted, %{}))  
  end

  def diffs2(map_a, map_b, key_path, result) when is_map(map_a) and is_map(map_b) do
    map_b
    |> Map.keys()
    |> Enum.reduce(result, fn k, map_changes ->
 
      map_a_value = Map.get(map_a, k) 
      %{^k => map_b_value} = map_b #map_b_value = Map.get(map_b, k) 
      new_key_path = [k | key_path]

      do_diffs2(map_b_value, new_key_path, map_a_value, map_changes )
    end)
  end

  def diffs2(map_a_value, map_b_value, _new_key_path, result) when map_a_value == map_b_value, do: result
  def diffs2(_map_a_value, _map_b_value, _new_key_path, result), do: result


  defp do_diffs2(map_b_value, new_key_path, nil, map_changes) do
    reversed_new_key_path = new_key_path |> Enum.reverse() 
    new_map_changes =
      Map.update!(
        map_changes,
        :deleted,
        &Map.put(&1, reversed_new_key_path, map_b_value)
      )
  end
  defp do_diffs2(map_b_value, new_key_path, map_a_value, map_changes) do
    diffs2(map_a_value, map_b_value, new_key_path, map_changes)
  end



  defp diffs(map_a, map_b, key_path, result) when is_map(map_a) and is_map(map_b) do
    map_b
    |> Map.keys()
    |> Enum.reduce(result, fn k, map_changes ->
 
      map_a_value = Map.get(map_a, k) 
      %{^k => map_b_value} = map_b #map_b_value = Map.get(map_b, k) 
      new_key_path = [k | key_path]

      do_diffs(map_b_value, new_key_path, map_a_value, map_changes )
    end)
  end

  defp diffs(map_a_value, map_b_value, _new_key_path, _) when map_a_value == map_b_value, do: :equals
  defp diffs(_map_a_value, _map_b_value, _new_key_path, _), do: :change
  
  defp do_diffs(map_b_value, new_key_path, nil, map_changes) do
    reversed_new_key_path = new_key_path |> Enum.reverse()

    new_map_changes =
      Map.update!(
        map_changes,
        :added,
        &Map.put(&1, reversed_new_key_path, map_b_value)
      )
  end

  defp do_diffs(map_b_value, new_key_path, map_a_value, map_changes) do
    new_map_changes=
    diffs(map_a_value, map_b_value, new_key_path, map_changes)
    |> check_diff_state( map_changes, new_key_path, map_b_value)
  end

  defp check_diff_state(:change, map_changes, new_key_path, map_b_value) do
    reversed_new_key_path = new_key_path |> Enum.reverse()
    Map.update!(map_changes, :changes, &Map.put(&1, reversed_new_key_path, map_b_value))
  end
  defp check_diff_state(:equals, map_changes, _, _), do: map_changes
  defp check_diff_state(map_changes, _, _, _), do: map_changes

end
