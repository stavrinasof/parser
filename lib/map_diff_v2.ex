defmodule MapDiffV2 do
  def diffs(map_a, map_b) when is_map(map_a) and is_map(map_b), do: diffs(map_a, map_b, [])

  defp diffs(map_a, map_b, key_path) when is_map(map_a) and is_map(map_b) do
    acc = %{:key_doesnt_exists => %{}, :changes => %{}}

    map_a
    |> Map.keys()
    |> Enum.reduce(acc, fn k, acc ->
      case Map.get(map_b, k) do
        nil ->
          Map.update!(acc, :key_doesnt_exists, &Map.put(&1, [k | key_path], Map.get(map_a, k)))

        map_b_value ->
          result = diffs(Map.get(map_a, k), map_b_value, [k | key_path])

          case result do
            {:ok, :equals} ->
              acc

            {:ok, :change} ->
              Map.update!(acc, :changes, &Map.put(&1, [k | key_path], map_b_value))

            _ ->
              acc
          end
      end
    end)
    |> IO.inspect()
  end

  defp diffs(map_a_value, map_b_value, key_path) when map_a_value == map_b_value,
    do: {:ok, :equals}

  defp diffs(map_a_value, map_b_value, key_path), do: {:ok, :change}
end
