defmodule XmlToMapOrderInAttr do
  require ID_Macros
  @upperclasses ['ContentAPI', 'Sport', 'SBClass', 'SBType', 'Ev']
  @lowerclasses ['Incident','Mkt', 'Seln']

  def naive_map(xml) do
    xml = String.replace(xml, ~r/\sxmlns=\".*\"/, "")
    {:ok, tuples, _} = :erlsom.simple_form(xml)
    parse(tuples,0)
  end

  # content is a charlist
  def parse(content,_order) when is_list(content) do
    to_string(content)
  end

  #attributes list is empty
  def parse({name, [], content},_order) when name in @upperclasses do
    do_parse_content(content, [], 0)
  end

  def parse({name, [], content},_order) do
    key = find_id_from_attributes(name, [])
    %{key => do_parse_content(content, [], 0)}
  end

  #content list is empty
  def parse({name, attributes, []}, order) when name in @lowerclasses do
    key = find_id_from_attributes(name, attributes)
    %{key => do_parse_attributes([{"order",order}|attributes])}
  end

  def parse({name, attributes, []}, _order) do
    key = find_id_from_attributes(name, attributes)
    %{key => do_parse_attributes(attributes)}
  end


  # Need to merge both attribute map and content map
  #there is attribute list and content list
  def parse({name, attributes, content},_order) when name in @upperclasses do
    map_content = do_parse_content(content, [], 0)
    key = find_id_from_attributes(name, attributes)
    Map.put(map_content, key, do_parse_attributes(attributes))
  end

  def parse({name, attributes, content}, order) when name in @lowerclasses do
    key = find_id_from_attributes(name, attributes)
    %{key => do_parse_content(content, [], 0) |> Map.merge(do_parse_attributes([{"order",order}|attributes]))}
  end

  def parse({name, attributes, content}, _order) do
    key = find_id_from_attributes(name, attributes)
    %{key => do_parse_content(content, [], 0) |> Map.merge(do_parse_attributes(attributes))}
  end


  # Helper function to parse content list and merge all maps into a larger map
  defp do_parse_content([], maps, _), do: Enum.reduce(maps, %{}, &MapActions.dynamic_merge(&1, &2))

  defp do_parse_content([h | t], acc, order) do
    ph = parse(h, order)
    case need_to_change_order(h) do
      true -> do_parse_content(t, [ph | acc], order+1)
      false -> do_parse_content(t, [ph | acc], order)
    end
  end

  def need_to_change_order({name,_,_}) when name in @lowerclasses ,do: true
  def need_to_change_order(_), do: false

  # Helper function to parse attribute list
  def do_parse_attributes(list) do
    list
    |> Enum.map(fn {k, v} -> {to_string(k), to_string(v)} end)
    |> Map.new()
  end

  # Helper function to build each key
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