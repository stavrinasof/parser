defmodule XmlToMap do
  require ID_Macros
  @upperclasses ['ContentAPI', 'Sport', 'SBClass', 'SBType', 'Ev']
  @lowerclasses ['Incident', 'Mkt', 'Seln', 'Price', 'Team']

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
    do_parse_content(content, [])
  end

  def parse({name, [], content}) when name=='Incidents' or name=='Teams' do
    key = find_id_from_attributes(name, []) 
    %{key => do_parse_content_l(content, [])}
  end

  def parse({name, [], content}) do
    key = find_id_from_attributes(name, [])
    %{key => do_parse_content(content, [])}
  end

  def parse({name, attributes, []}) when name in @lowerclasses do
    do_parse_attributes(attributes)
  end

  def parse({name, attributes, []}) do
    key = find_id_from_attributes(name, attributes)
    %{key => do_parse_attributes(attributes)}
  end

  # Need to merge both attribute map and content map

  def parse({name, attributes, content}) when name in @upperclasses do
    map_content = do_parse_content(content, [])
    key = find_id_from_attributes(name, attributes)
    Map.put(map_content, key, do_parse_attributes(attributes))
  end

  def parse({name, attributes, content}) when name in @lowerclasses do
    %{to_string(name) => do_parse_content(content, []) |> Map.merge(do_parse_attributes(attributes))}
  end

  def parse({name, attributes, content}) do
    key = find_id_from_attributes(name, attributes)
    %{key => do_parse_content(content, []) |> Map.merge(do_parse_attributes(attributes))}
  end

  defp do_parse_content_l([], maps), do: maps
  defp do_parse_content_l([h | t], acc) do
    ph = parse(h)
    do_parse_content_l(t, [ph | acc])
  end

  # Helper function to parse content list and merge all maps into a larger map
  defp do_parse_content([], maps) do
    Enum.reduce(maps, %{}, &MapActions.dynamic_merge(&1, &2))
  end

  defp do_parse_content([h | t], acc) do
    ph = parse(h)
    do_parse_content(t, [ph | acc])
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
