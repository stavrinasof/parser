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
                                                       check_diff_state(state,{acc, deleted_map_a}, [k | key_path], Map.get(map_b, k))
                                                       
                                    end
    end)
  end


  defp diffs(map_a_value, map_b_value, [h|_t]=new_key_path , {_result, map_a_copy}) when map_a_value == map_b_value do
   {_, new_map_a_copy}=
    map_a_copy
    |> pop_in(Enum.reverse(new_key_path))
    
   {{:ok, :equals}, new_map_a_copy}
  end
  defp diffs(map_a_value, map_b_value, [h|_t]= new_key_path, {_result, map_a_copy}) do 
    {_, new_map_a_copy}=
    map_a_copy
    |> pop_in(Enum.reverse(new_key_path))
    |> IO.inspect
    {{:ok, :change}, new_map_a_copy}
  end
  defp check_diff_state({:ok, :change}, {acc, deleted_map_a}, new_key_path, map_b_value) do
   reversed_new_key_path = new_key_path |> Enum.reverse
   {Map.update!(acc, :changes, &Map.put(&1, reversed_new_key_path, map_b_value)), deleted_map_a}
  end
  defp check_diff_state({:ok, :equals}, {acc, deleted_map_a}, _,_), do: {acc, deleted_map_a}
  defp check_diff_state(result, {_,deleted_map_a}, _,_), do: {result, deleted_map_a}
end
