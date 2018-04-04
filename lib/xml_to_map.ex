defmodule XmlToMap do
  require ID_Macros
  @upperclasses ['ContentAPI', 'Sport', 'SBClass', 'SBType', 'Ev']

  def naive_map(xml) do
    xml = String.replace(xml, ~r/\sxmlns=\".*\"/, "")
    {:ok, tuples, _} = :erlsom.simple_form(xml)
    parse(tuples)
  end

  # content is a charlist
  def parse(content) when is_list(content) do
    to_string(content)
  end

  def parse({name, [], content}) when name in @upperclasses do
    do_parse_content(content, [], 0)
  end

  def parse({name, [], content},order) do
    key = find_id_from_attributes(name, [])
    case is_tuple(key) do
      true -> %{{key,order+1} => do_parse_content(content, [], 0)}
      false -> %{key => do_parse_content(content, [], 0)}
    end
    end

  def parse({name, attributes, []}, order) do
    key = find_id_from_attributes(name, attributes)
    case is_tuple(key) do
      true -> %{{key,order} => do_parse_attributes(attributes)} #
      false -> %{key => do_parse_attributes(attributes)}
    end    
  end

  # Need to merge both attribute map and content map

  def parse({name, attributes, content}) when name in @upperclasses do
    map_content = do_parse_content(content, [], 0)
    key = find_id_from_attributes(name, attributes)
    Map.put(map_content, key, do_parse_attributes(attributes))
  end

  def parse({name, attributes, content}, order) do
    key = find_id_from_attributes(name, attributes)
    case is_tuple(key)do
      true -> %{{key, order} => do_parse_content(content, [], 0) |> Map.merge(do_parse_attributes(attributes))}
      false -> %{key => do_parse_content(content, [], 0) |> Map.merge(do_parse_attributes(attributes))}
    end
  end


  # Helper function to parse content list and merge all maps into a larger map
  defp do_parse_content([], maps, _), do: Enum.reduce(maps, %{}, &MapActions.dynamic_merge(&1, &2))

  defp do_parse_content([h | t], acc, order) do
    ph = parse(h, order)
    do_parse_content(t, [ph | acc], order+1)
  end

  def do_parse_attributes(list) do
    list
    |> Enum.map(fn {k, v} -> {to_string(k), to_string(v)} end)
    |> Map.new()
  end

  def find_id_from_attributes(tagname, []), do: to_string(tagname)

  def find_id_from_attributes(tagname, list) do
    list
    |> Enum.reduce_while({}, fn x, _ ->
      case do_find_id_from_attributes(x, tagname) do
        nil -> {:cont, to_string(tagname)}
        key -> {:halt, key}
      end
    end)
  end

  ID_Macros.in_list()
  ID_Macros.not_in_list()
end
