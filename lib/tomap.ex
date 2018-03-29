defmodule ToMap do
  @ids ['mkt_id','ev_id','seln_id' ,'sb_class_id','sb_type_id','incident_id','team_id','period','inplay_period_num','sport_code','stat_type','player_id']

  def naive_map(xml) do
    #can't handle xmlns
    xml = String.replace(xml, ~r/\sxmlns=\".*\"/, "")
    {:ok, tuples, _} = :erlsom.simple_form(xml)
    # IO.inspect tuples
    parse(tuples)
  end

  def parse( {name, [], content} ) do
    key =find_id_from_attributes(name, [])
    %{key =>do_parse_content(content,[])}
  end

  def parse( {name, attributes, []} ) do
    key=find_id_from_attributes(name, attributes)
    %{key => attr_map(attributes)}
  end

  def parse( {name, attributes, content} ) do
    key = find_id_from_attributes(name, attributes)

    %{key =>do_parse_content(content,[]) |> Map.merge(attr_map(attributes))}
  end

  def do_parse_content([],maps) do
    [h|t] = maps
    similarmaps = keys_repair(h,t,[])

    Enum.reduce(maps,%{},fn m,acc -> Map.merge(m,acc) end)
  end
  def do_parse_content([h|t],acc) do
   ph = parse(h)
   do_parse_content(t,[ph |acc])
  end


  defp attr_map(list) do
    list |> Enum.map(fn {k,v} -> {to_string(k), to_string(v)} end) |> Map.new
  end

  defp find_id_from_attributes(tagname, []) do
    {to_string(tagname)}
  end

  defp find_id_from_attributes(tagname, list) do

      list
      |> Enum.filter(fn {attrname,attrvalue} -> attrname in @ids end)
      |> do_find_id_from_attributes(tagname)
  end


  def do_find_id_from_attributes([], tagname), do: {to_string(tagname)}
  def do_find_id_from_attributes([{_,attrvalue}], tagname), do: {to_string(tagname), attrvalue}

 def do_find_id_from_attributes(results, tagname) do

  #  attrvalue=
  #   Enum.filter results, fn {attrname, attrvalue} -> Regex.match?(~r/String.downcase( to_string(tagname))/, (attrname))   end
  #  |> List.first
  #  |> elem(1)

    results =
    Enum.filter results, fn {attrname, attrvalue} -> attrname in @ids end

    {attrname,attrvalue}=
      case tagname do
        'Seln'  -> List.last(results)
        'Incident' -> List.last(results)
        _      -> IO.inspect "AAAAAAAAAAAAAAAAAAAAAA #{tagname}"
                  List.first(results)
      end

    {to_string(tagname), attrvalue}

  end

  def keys_repair(map, [resth | restt]=restmaps , acc) do
    restkeys =
      Enum.map(restmaps,&Map.keys/1)
      |>List.flatten()
    mapkey =
      Map.keys(map)
      |>List.first
    case mapkey in restkeys do
      true -> keys_repair(resth, restt, [map|acc])
      false -> keys_repair(resth, restt, acc)
    end
  end


end
