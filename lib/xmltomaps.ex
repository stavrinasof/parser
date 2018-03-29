defmodule XmlToMaps do
  @ids ['mkt_id','ev_id','seln_id' ,'sb_class_id','sb_type_id','incident_id','team_id','period','inplay_period_num','sport_code']
  def naive_map(xml) do
    #can't handle xmlns
    xml = String.replace(xml, ~r/\sxmlns=\".*\"/, "")
    {:ok, tuples, _} = :erlsom.simple_form(xml)
    #IO.inspect tuples
    parse(tuples)
  end

  def parse([value]) do
    case is_tuple(value) do
      true -> parse(value)
      false -> to_string(value) |> String.trim
    end
  end

  def parse({name, [],content}) do
    parsed_content = parse(content)
    key=find_id_from_attributes(name,[])
    |>IO.inspect
    %{key => parsed_content} |>IO.inspect
  end

  def parse({name, attr, []}) do
    key= find_id_from_attributes(name,attr)
    #IO.inspect name
    map =%{key => attr_map(attr)}
  end

  def parse({name, attr, content}) do
    parsed_content = parse(content)
    key=find_id_from_attributes(name,attr)
    case is_map(parsed_content) do
      true ->
        %{key => parsed_content |> Map.merge(attr_map(attr))}
      false ->
        %{key => parsed_content}
    end
  end

  def parse(list) when is_list(list) do
    parsed_list = Enum.map list, &({to_string(elem(&1,0)), parse(&1)})
    #parsed_list = Enum.map list, &( parse(&1))
    #IO.inspect parsed_list ,label: "Incidents"
     Enum.reduce parsed_list, %{}, fn {k,v}, acc ->
       case Map.get(acc, k) do
         nil -> Map.put_new(acc, k, v[k])
         [h|t] -> Map.put(acc, k, [h|t] ++ [v[k]])
         prev -> Map.put(acc, k, [prev] ++ [v[k]])
       end
     end
  end

  defp attr_map(list) do
    list |> Enum.map(fn {k,v} -> {to_string(k), to_string(v)} end) |> Map.new
  end

  defp find_id_from_attributes(tagname, []) do
    {to_string(tagname)}
  end

  defp find_id_from_attributes(tagname, list) do
    results =
      list |> Enum.filter(fn {attrname,attrvalue} -> attrname in @ids end)
    # |> IO.inspect
    IO.inspect tagname
    {attrname,attrvalue}=
      case tagname do
        'Seln' -> List.last(results)
        _ -> List.first(results)
      end

    {to_string(tagname), attrvalue}
  end
  
end
