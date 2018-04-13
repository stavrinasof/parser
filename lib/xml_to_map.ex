defmodule XmlToMap do
  require ID_Macros
  @upperclasses ['ContentAPI', 'Sport', 'SBClass', 'SBType']

  def naive_map(xml) do
    xml = String.replace(xml, ~r/\sxmlns=\".*\"/, "")
    {:ok, tuples, _} = :erlsom.simple_form(xml)
    parse(tuples) |>Map.new
  end

  # content is a charlist
  def parse(content) when is_list(content) do
    {:chars ,content}
  end

  def parse({name, [], content}) when name in @upperclasses do
    do_parse_content_upper(content, [])
  end

  def parse({name, [], content}) do
    key = find_id_from_attributes(name, [])
    {key , do_parse_content(content, [])}
  end

  def parse({name, attributes, []}) do
    key = find_id_from_attributes(name, attributes)
    {key , do_parse_attributes(attributes)}
  end

  # Need to merge both attribute map and content map

  def parse({name, attributes, content}) when name in @upperclasses do
    map_content_tuple = do_parse_content_upper(content, [])
    key = find_id_from_attributes(name, attributes)
    case is_list(map_content_tuple) do
      true -> [{key ,do_parse_attributes(attributes)} |map_content_tuple]
      false ->  [{key ,do_parse_attributes(attributes)} ,map_content_tuple ]
   end
  end

  def parse({name, attributes, content}) do
    key = find_id_from_attributes(name, attributes)
    {key , do_parse_content(content, []) |> Map.merge(do_parse_attributes(attributes))}
  end

  defp do_parse_content_upper([], [tuple_maps]), do: tuple_maps
  defp do_parse_content_upper([h | t], acc) do
    ph = parse(h)
    do_parse_content_upper(t, [ph | acc])
  end

  # Helper function to parse content list and merge all maps into a larger map
  defp do_parse_content([], tuple_maps), do: Map.new(tuple_maps)
  #Enum.reduce(tuple_maps, %{}, &MapActions.dynamic_merge(&1, &2))

  defp do_parse_content([h | t], acc) do
    ph = parse(h)
    do_parse_content(t, [ph | acc])
  end

  def do_parse_attributes(list) do
    list
    |> Enum.map(fn {k, v} -> {k, v} end)
    |> Map.new()
  end

  def find_id_from_attributes(tagname, []), do: tagname

  def find_id_from_attributes(tagname, list) do
    list
    |> Enum.reduce_while({}, fn x, _ ->
      case do_find_id_from_attributes(x, tagname) do
        nil -> {:cont, tagname}
        key -> {:halt, key}
      end
    end)
  end

  ID_Macros.in_list()
  ID_Macros.not_in_list()
end
