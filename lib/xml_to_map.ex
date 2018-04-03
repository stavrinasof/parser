defmodule Macroo do
@ids [
    {'Mkt', 'mkt_id'},
    {'Seln', 'seln_id'},
    {'Incident', 'incident_id'},
    {'Team', 'team_id'},
    {'PeriodScore','period'},
    {'Inplay', 'inplay_period_num'},
    {'Player', 'player_id'},
    {'EvDetail', 'br_match_id'},
    {'Participant', 'full_name'},
    {'Score', 'name'},
    {'MatchStatus', 'status_code'},
    {'Price', 'prc_type'},
    {'InplayDetail','period_start'},
    {'MatchStat','name'}
  ]

  defmacro my_macro1() do
   tagname = (Macro.var(:"tagname", __MODULE__))
  
    quote do
      def do_find_id_from_attributes(_, unquote(tagname)) do 
        unquote(nil)
      end
    end
  end

  defmacro my_macro2() do
    attrvalue = (Macro.var(:"attrvalue", __MODULE__))

    @ids
    |> Enum.map( fn {tagname, attrname} -> 
        quote do
          def do_find_id_from_attributes({unquote(attrname),unquote(attrvalue)}, unquote(tagname)) do
              a= to_string(unquote(tagname))
              {a, to_string(unquote(attrvalue))}
           end
        end
    end) 
    
    

  end
end

defmodule XmlToMap do
  require Macroo
  @upperclasses [ 'ContentAPI','Sport','SBClass','SBType' ,'Ev']

 
  def naive_map(xml) do
    # can't handle xmlns
    xml = String.replace(xml, ~r/\sxmlns=\".*\"/, "")
    {:ok, tuples, _} = :erlsom.simple_form(xml)
    parse(tuples)
  end

  def parse({name, [], content}) when name in @upperclasses do
    do_parse_content(content, [])
  end

  def parse({name, [], content}) do
    key = find_id_from_attributes(name, [])
    %{key => do_parse_content(content, [])}
  end

  def parse({name, attributes, []}) do
    key = find_id_from_attributes(name, attributes)
    %{key => do_parse_attributes(attributes)}
  end

  # Need to merge both attribute map and content map

  def parse({name, attributes, content}) when name in @upperclasses do
    map_content = do_parse_content(content, [])
    key = find_id_from_attributes(name, attributes)
    Map.put(map_content, key ,do_parse_attributes(attributes))
  end

  def parse({name, attributes, content}) do
    key = find_id_from_attributes(name, attributes)
    %{key => do_parse_content(content, []) |> Map.merge(do_parse_attributes(attributes))}
  end

  # Helper function to parse content list and merge all maps into a larger map
  defp do_parse_content([], maps), do: Enum.reduce(maps, %{}, &dynamic_merge(&1, &2))

  defp do_parse_content([h | t], acc) do
    ph = parse(h)
    do_parse_content(t, [ph | acc])
  end

  # Function to reduce maps' list
  def dynamic_merge(map, acc) when acc == %{}, do: map

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

  def do_parse_attributes(list) do
    list
    |> Enum.map(fn {k, v} -> {to_string(k), to_string(v)} end)
    |> Map.new()
  end

  def find_id_from_attributes(tagname, []), do: to_string(tagname)

  def find_id_from_attributes(tagname, list) do
    list
    |> Enum.reduce_while({}, fn x, acc ->    case do_find_id_from_attributes(x, tagname) do
                                                nil -> {:cont, acc}     
                                                key -> {:halt, key}     
                                               end
                             end)
  end

  Macroo.my_macro2
  Macroo.my_macro1
  # defp do_find_id_from_attributes({ 'mkt_id', attrvalue}, 'Mkt'=tagname), do: {to_string(tagname), to_string(attrvalue)}
  # defp do_find_id_from_attributes({ 'seln_id', attrvalue}, 'Seln'=tagname), do: {to_string(tagname), to_string(attrvalue)}
  # defp do_find_id_from_attributes({ 'incident_id', attrvalue}, 'Incident'=tagname), do: {to_string(tagname), to_string(attrvalue)}
  # defp do_find_id_from_attributes({ 'team_id', attrvalue}, 'Team'=tagname), do: {to_string(tagname), to_string(attrvalue)}
  # defp do_find_id_from_attributes({ 'period', attrvalue}, 'PeriodScore'=tagname), do: {to_string(tagname), to_string(attrvalue)}
  # defp do_find_id_from_attributes({ 'inplay_period_num', attrvalue}, 'Inplay'=tagname), do: {to_string(tagname), to_string(attrvalue)}
  # defp do_find_id_from_attributes({ 'stat_type', attrvalue}, 'Stat'=tagname), do: {to_string(tagname), to_string(attrvalue)}
  # defp do_find_id_from_attributes({ 'player_id', attrvalue}, 'Player'=tagname), do: {to_string(tagname), to_string(attrvalue)}
  # defp do_find_id_from_attributes({ 'br_match_id', attrvalue}, 'EvDetail'=tagname), do: {to_string(tagname), to_string(attrvalue)}
  # defp do_find_id_from_attributes({ 'full_name', attrvalue}, 'Participant'=tagname), do: {to_string(tagname), to_string(attrvalue)}
  # defp do_find_id_from_attributes({ 'name', attrvalue}, 'Score'=tagname), do: {to_string(tagname), to_string(attrvalue)}
  # defp do_find_id_from_attributes({ 'status_code', attrvalue}, 'MatchStatus'=tagname), do: {to_string(tagname), to_string(attrvalue)}
  # defp do_find_id_from_attributes({ 'prc_type', attrvalue},'Price'=tagname), do: {to_string(tagname), to_string(attrvalue)}
  # defp do_find_id_from_attributes({ 'period_start', attrvalue},'InplayDetail'=tagname), do: {to_string(tagname), to_string(attrvalue)}
  # defp do_find_id_from_attributes(_, tagname), do: nil


  # defp do_find_id_from_attributes(results, tagname) do
  #   # results = Enum.filter(results, fn {attrname, _attrvalue} -> attrname in @ids end)

  #   {_attrname, attrvalue} =
  #     case tagname do
  #       'Seln' ->
  #         List.last(results)

  #       'Incident' ->
  #         List.last(results)

  #       _ ->
  #         IO.inspect("#{tagname}")
  #         List.first(results)
  #     end

  #   {to_string(tagname), to_string(attrvalue)}
  # end
end
