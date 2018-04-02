defmodule MapDiff do
  def diffs(map_a, map_b) when is_map(map_a) and is_map(map_b), do: diffs(map_a, map_b, [], %{:key_doesnt_exist => %{}, :changes => %{}})

  defp diffs(map_a, map_b, key_path, acc) when is_map(map_a) and is_map(map_b) do

    map_b
    |> Map.keys()
    |> Enum.reduce(acc, fn k, acc -> 
                                    case Map.get(map_a, k) do
                                        nil         -> reversed_new_key_path = [k | key_path] |> Enum.reverse
                                                       Map.update!(acc, :key_doesnt_exist, &Map.put(&1, reversed_new_key_path, Map.get(map_b, k)))
                                        map_a_value -> diffs(map_a_value, Map.get(map_b, k), [k | key_path], acc)
                                                       |> check_diff_state(acc, [k | key_path], Map.get(map_b, k))
                                    end
    end)
  end


  defp diffs(map_a_value, map_b_value, key_path, _result) when map_a_value == map_b_value, do: {:ok, :equals}

  defp diffs(map_a_value, map_b_value, key_path, _result), do: {:ok, :change}

  defp check_diff_state({:ok, :change}, acc, new_key_path, map_b_value) do
   reversed_new_key_path = new_key_path |> Enum.reverse
   Map.update!(acc, :changes, &Map.put(&1, reversed_new_key_path, map_b_value))
  end
  defp check_diff_state({:ok, :equals}, acc, _,_), do: acc
  defp check_diff_state(result, _, _,_), do: result
end
