defmodule MapDiff do
  def diffs(map_a, map_b) when is_map(map_a) and is_map(map_b), do: diffs(map_a, map_b, [], {%{:key_doesnt_exist => %{}, :changes => %{}}, map_a})

  defp diffs(map_a, map_b, key_path, {acc, map_a_copy}) when is_map(map_a) and is_map(map_b) do

    map_b
    |> Map.keys()
    |> Enum.reduce({acc, map_a_copy}, fn k, {acc, map_a_c} -> 
                                    case Map.get(map_a, k) do
                                        nil         -> reversed_new_key_path = [k | key_path] |> Enum.reverse
                                                       new_acc = Map.update!(acc, :key_doesnt_exist, &Map.put(&1, reversed_new_key_path, Map.get(map_b, k)))
                                                      {new_acc, map_a_c}
                                        map_a_value -> {state, deleted_map_a} =diffs(map_a_value, Map.get(map_b, k), [k | key_path], {acc, map_a_c})
                                                       new_map_changes  = check_diff_state(state, acc, [k | key_path], Map.get(map_b, k))

                                                       {new_map_changes, deleted_map_a}
                                                       
                                    end
    end)
  end

 defp delete(map_a_c, new_key_path) do
    map_a_c
    |>pop_in(Enum.reverse(new_key_path))
    |> elem(1)
  end


  defp diffs(map_a_value, map_b_value, new_key_path , {_result, map_a_copy}) when map_a_value == map_b_value do
   {{:ok, :equals}, delete(map_a_copy, new_key_path )}
  end
  defp diffs(map_a_value, map_b_value, new_key_path, {_result, map_a_copy}) do 
    {{:ok, :change}, delete(map_a_copy, new_key_path )}
  end

  defp check_diff_state({:ok, :change}, acc, new_key_path, map_b_value) do
   reversed_new_key_path = new_key_path |> Enum.reverse
   Map.update!(acc, :changes, &Map.put(&1, reversed_new_key_path, map_b_value))
  end
  defp check_diff_state({:ok, :equals}, acc, _,_), do: acc
  defp check_diff_state(result, _, _,_), do: result |> IO.inspect
end