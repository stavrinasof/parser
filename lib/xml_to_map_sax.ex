defmodule XmlToMapSax do
  def saxmap(xml) do
    xml = String.replace(xml, ~r/\sxmlns=\".*\"/, "")
    :erlsom.parse_sax(xml, [], fn xmline,acc -> parse_element(xmline,acc)  end)
    |>elem(1)
    |>List.first
    |>elem(1)

    # |>Enum.reduce([],&my_reduce_fun(&1,&2))
    # |>Enum.reduce(%{},&Map.merge(&2,&1))
  end

  defp parse_attributes([],attrmap) ,do: attrmap
  defp parse_attributes([{:attribute, attrname, [], [], attrvalue}|attrlist],attrmap) do
    attrmap = Map.put(attrmap,to_string(attrname),to_string(attrvalue))
    parse_attributes(attrlist,attrmap)
  end


  def parse_element(:startDocument,[]) ,do: []
  def parse_element(:endDocument,acc_tuples) ,do: acc_tuples
  def parse_element({:startElement, [], tagname, [], attrlist} ,acc_tuples) do
    [{to_string(tagname),parse_attributes(attrlist,%{})} |acc_tuples ]
  end

  def parse_element({:characters, characters} ,acc_tuples) ,do: [{:chars,to_string(characters)}|acc_tuples]
  def parse_element({:ignorableWhitespace, _} ,acc_tuples) ,do: acc_tuples
  def parse_element({:endElement, [], tagname, []},acc_tuples) do
    name =to_string(tagname)
    index= Enum.find_index(acc_tuples, fn x -> elem(x,0) ==name end)
    map_inner=
      acc_tuples
      |> Enum.take(index+1)
      |> Enum.reduce(%{},fn {_,m} , acc -> MapActions.dynamic_merge(m,acc) end)
     # |> IO.inspect
    rest_tuples= Enum.drop(acc_tuples,index+1)
    [{name,%{name=> map_inner}}|rest_tuples]
  end
end
