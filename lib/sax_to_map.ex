defmodule SaxToMap do
  def saxmap(xml) do
    xml = String.replace(xml, ~r/\sxmlns=\".*\"/, "")
    :erlsom.parse_sax(xml, [], fn xmline,acc -> parse_element(xmline,acc) end)
    |>elem(1)
    |>Enum.reduce([],&my_reduce_fun(&1,&2))
    |>Enum.reduce(%{},&Map.merge(&2,&1))

  end

  defp my_reduce_fun({name,map} ,acc) do
    case Map.get(map,name) do
      nil -> [%{name =>map}| acc]
      _ -> [map |acc]
    end
  end

  def parse_attributes([],attrmap) ,do: attrmap
  def parse_attributes([{:attribute, attrname, [], [], attrvalue}|attrlist],attrmap) do
    attrmap = Map.put(attrmap,to_string(attrname),to_string(attrvalue))
    parse_attributes(attrlist,attrmap)
  end

  def parse_element(:startDocument,[]) ,do: []
  def parse_element(:endDocument,acc_tuples) ,do: acc_tuples
  def parse_element({:startElement, [], element, [], attrlist} ,acc_tuples) do
    attrmap = parse_attributes(attrlist,%{})
    case Map.keys(attrmap) do
      [] -> acc_tuples
      _ -> [{to_string(element),attrmap}|acc_tuples]
    end
  end

  def parse_element({:endElement, [], element, []},acc_tuples) do
    name=to_string(element)
    case elem(List.first(acc_tuples),0) do
      ^name ->
        [{_,hmap}|tailmaps] = Enum.filter(acc_tuples ,fn x -> elem(x,0) == name end)
        map2 =Enum.reduce(tailmaps,%{name => hmap},fn {_,m} ,acc -> MapActions.dynamic_merge(acc,m)end)
        rest_tuples = Enum.reject(acc_tuples ,fn x -> elem(x,0) == name end)
        [{name,map2}|rest_tuples]
        _ ->  acc_tuples
    end
  end

  def parse_element({:ignorableWhitespace, _} ,acc_tuples) ,do: acc_tuples

end
