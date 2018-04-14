defmodule MapDiff do
  def diffs(map_a, map_b) when is_map(map_a) and is_map(map_b),
    do: diffs(map_a, map_b, [], {%{:key_doesnt_exist => %{}, :changes => %{}}, map_a})

  defp diffs(map_a, map_b, key_path, result) when is_map(map_a) and is_map(map_b) do
    map_b
    |> Map.keys()
    |> Enum.reduce(result, fn k, {map_changes, map_a_c} ->
 
      map_a_value = Map.get(map_a, k) 
      %{^k => map_b_value} = map_b #map_b_value = Map.get(map_b, k) 
      new_key_path = [k | key_path]

      do_diffs(map_b_value, new_key_path, map_a_value, {map_changes, map_a_c})
    end)
  end

  defp diffs(map_a_value, map_b_value, new_key_path, {_, map_a_copy})
       when map_a_value == map_b_value do
    {:equals, delete_in(map_a_copy, new_key_path)}
  end

  defp diffs(_map_a_value, _map_b_value, new_key_path, {_, map_a_copy}) do
    {:change, delete_in(map_a_copy, new_key_path)}
  end

  defp do_diffs(map_b_value, new_key_path, nil, {map_changes, map_a_c}) do
    reversed_new_key_path = new_key_path |> Enum.reverse()

    new_map_changes =
      Map.update!(
        map_changes,
        :key_doesnt_exist,
        &Map.put(&1, reversed_new_key_path, map_b_value)
      )

    {new_map_changes, map_a_c}
  end

  defp do_diffs(map_b_value, new_key_path, map_a_value, {map_changes, map_a_c}) do
    {state, deleted_map_a} = diffs(map_a_value, map_b_value, new_key_path, {map_changes, map_a_c})
    new_map_changes = check_diff_state(state, map_changes, new_key_path, map_b_value)

    {new_map_changes, deleted_map_a}
  end

  def delete_in(map_a_c, new_key_path) do
    map_a_c
    |> my_pop_in(Enum.reverse(new_key_path))
  end

  defp check_diff_state(:change, map_changes, new_key_path, map_b_value) do
    reversed_new_key_path = new_key_path |> Enum.reverse()
    Map.update!(map_changes, :changes, &Map.put(&1, reversed_new_key_path, map_b_value))
  end

  defp check_diff_state(:equals, map_changes, _, _), do: map_changes
  defp check_diff_state(map_changes, _, _, _), do: map_changes

  defp my_pop_in(map, []), do: map

  defp my_pop_in(map, [key]) do
    Map.delete(map, key)
  end

  defp my_pop_in(map, [head_key | tail_keypath]) do
    value_map = Map.get(map, head_key)
    new_value_map = my_pop_in(value_map, tail_keypath)

    case Map.equal?(new_value_map, %{}) do
      true -> Map.delete(map, head_key)
      false -> Map.put(map, head_key, new_value_map)
    end
  end
end
