defmodule MapDiff do
  def diffs(map_a, map_b) when is_map(map_a) and is_map(map_b), do: diffs(map_a, map_b, [], %{:key_doesnt_exist => %{}, :changes => %{}})

  defp diffs(map_a, map_b, key_path, acc) when is_map(map_a) and is_map(map_b) do
    # acc = %{:key_doesnt_exist => %{}, :changes => %{}}

    map_b
    |> Map.keys()
    |> Enum.reduce(acc, fn k, acc ->
                                    case Map.get(map_a, k) do
                                      nil         -> Map.update!(acc, :key_doesnt_exist, &Map.put(&1, [k | key_path], Map.get(map_b, k)))
                                      map_a_value -> result = diffs(Map.get(map_b, k), map_a_value, [k | key_path], acc)

                                        case result do
                                          {:ok, :equals} -> acc
                                          {:ok, :change} -> Map.update!(acc, :changes, &Map.put(&1, [k | key_path], Map.get(map_b, k)))
                                          _              -> result
                                        end
                                    end
    end)
    |> IO.inspect()
  end

  defp diffs(map_a_value, map_b_value, key_path, _result) when map_a_value == map_b_value, do: {:ok, :equals}

  defp diffs(map_a_value, map_b_value, key_path, _result), do: {:ok, :change}
end
