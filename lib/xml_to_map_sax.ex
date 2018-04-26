defmodule XmlToMapSax do
  require ID_Macros
  ID_Macros.in_list()
  ID_Macros.not_in_list()

  @upperclasses ['Sport','SBClass','SBType']
  def saxmap(xml) do
    xml = String.replace(xml, ~r/\sxmlns=\".*\"/, "",global: false)
    :erlsom.parse_sax(xml, [], fn xmline,acc -> parse_element(xmline,acc)  end)
    |>elem(1)
    |>Enum.reduce([],fn {_,m}, acc ->[m|acc] end )
    |>Map.new
    # |>elem(1)

  end

  defp parse_attributes([],attr_tuplelist) ,do: Map.new(attr_tuplelist)
  defp parse_attributes([{:attribute, attrname, [], [], attrvalue}|attrlist],attr_tuplelist) do
    parse_attributes(attrlist, [{attrname,attrvalue} |attr_tuplelist])
  end


  def parse_element(:startDocument,[]) ,do: []
  def parse_element(:endDocument,acc_tuples) ,do: acc_tuples
  def parse_element({:startElement, [], 'ContentAPI', [], _attrlist} ,acc_tuples) ,do:  acc_tuples
  def parse_element({:startElement, [], tagname, [], attrlist} ,acc_tuples) when tagname in @upperclasses do
    [{tagname,{tagname, parse_attributes(attrlist,[])}} |acc_tuples ]
  end
  def parse_element({:startElement, [], tagname, [], attrlist} ,acc_tuples) do
    attrmap = parse_attributes(attrlist,[])
    case  Enum.empty?(attrmap)do
      true -> [{tagname,[]}|acc_tuples]
      false ->
        key=find_id_from_attributes(tagname, attrlist)
        [{tagname,{key, attrmap}} |acc_tuples ]
    end
  end

  def parse_element({:characters, characters} ,acc_tuples) ,do: [{:characters,{'chars',characters}}|acc_tuples]
  def parse_element({:ignorableWhitespace, _} ,acc_tuples) ,do: acc_tuples
  def parse_element({:endElement, [], tagname, []},acc_tuples) when tagname in @upperclasses or tagname=='ContentAPI' do
    acc_tuples
  end
  def parse_element({:endElement, [], tagname, []},[{tagname,_map_inner}|_]=acc_tuples) ,do: acc_tuples
  def parse_element({:endElement, [], tagname, []},acc_tuples) do
    {tuples_inner,[ele_tuple|rest_tuples]}= Enum.split_while(acc_tuples, fn x -> elem(x,0) ==tagname   end)
    map_inner=
      tuples_inner |>IO.inspect
      |> Enum.reduce([],fn {_,tuple} , acc -> [tuple|acc] end)
      |>Map.new
      IO.inspect(map_inner,label: "#{tagname}")

      {tagname,value}=ele_tuple
      case value do
        [] ->
          ttuple={tagname,{tagname,map_inner}}|>IO.inspect(label: "1")
          [ttuple|rest_tuples]
        {key,attrmap} ->
          ttuple={key,{key,Map.merge(attrmap,map_inner)}}|>IO.inspect
          [ttuple|rest_tuples]
      end
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


end
