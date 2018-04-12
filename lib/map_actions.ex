defmodule MapActions do
  # Function to reduce maps' list
  def dynamic_merge(map, acc) when acc == %{}, do: map
  def dynamic_merge(map, acc) when map ==%{} ,do: acc
  def dynamic_merge(map, acc) do
    keys=Map.keys(map)
    case length(keys) do
      1->
        key = List.first(keys)
        Map.get(acc, key)
        |> dynamic_update_value(map , acc)
      _ -> #map is the attributes map
        Map.merge(acc,map)
    end
  end

  #map's key is not a key in acc
  defp dynamic_update_value(nil, map, acc) do
    Map.merge(map, acc)
  end

  #acc has key=>rest_values
  #need to add a member in the list
  defp dynamic_update_value(rest_values, map, acc) when is_list(rest_values) do
    [value] = Map.values(map)
    [key] = Map.keys(map)
    Map.put(acc, key, [value| rest_values])
  end

  #acc has key=>rest_values that is a map
  defp dynamic_update_value(rest_values, map, acc) when is_map(rest_values) do
    [value] = Map.values(map)
    [key] = Map.keys(map)
    Map.put(acc, key, [value , rest_values])
  end

end
