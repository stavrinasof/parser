defmodule MapActions do
  # Function to reduce maps' list
  def dynamic_merge({key,map}, acc) when acc == %{}, do: map

  def dynamic_merge(map, acc) do
    [key] = Map.keys(map)

    case key do
      {_keyname, _keyid} ->
        # given map is of same hierachy as the other maps in acc
        Map.merge(map, acc)

      _keyname ->
        # given map needs to be member of a list



        # that is a value of a map of same hierachy as the other maps in acc
        Map.get(acc, key)
        |> dynamic_update_value(map, acc)
    end
  end

  defp dynamic_update_value(nil, map, acc) do
    Map.merge(map, acc)
  end

  defp dynamic_update_value(rest_values, map, acc) when is_list(rest_values) do
    [value] = Map.values(map)
    [key] = Map.keys(map)
    Map.put(acc, key, [value | rest_values])
  end

  defp dynamic_update_value(rest_values, map, acc) do
    [value] = Map.values(map)
    [key] = Map.keys(map)
    Map.put(acc, key, [value | [rest_values]])
  end
end
