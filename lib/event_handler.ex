defmodule EventHandler do
  @behaviour Saxy.Handler
  require ID_Macros_Saxy

  ID_Macros_Saxy.in_list()
  ID_Macros_Saxy.not_in_list()

  @upper_classes ["ContentAPI", "Sport", "SBClass", "SBType"]

  def handle_event(:start_document, prolog, state) do
    {:ok, state}
  end

  def handle_event(:end_document, _data,  state) do
    new_state = 
    state  
    |>Enum.reduce([],fn {_,m}, acc ->[m|acc] end )
    |>Map.new
    {:ok, new_state}
  end

   def handle_event(:start_element, {"ContentAPI", attributes}, state) do
    {:ok, state} 
  end

  def handle_event(:start_element, {name, attributes}, state) when name in @upper_classes do
    {:ok,  [{name,{name, parse_attributes(attributes)}}|state]} 
  end

  def handle_event(:start_element, {name, []}, state) do
    {:ok,  [{name,[]}|state]} 
  end

  def handle_event(:start_element, {name, attributes}, state) do

    {:ok,[{name, {find_id_from_attributes(name, attributes), parse_attributes(attributes) } }|state]}
  end

  def handle_event(:characters, characters, state) do
    {:ok, [{:characters,{:chars,characters}}|state]} 
  end

  #END_ELEMENT
  
  def handle_event(:end_element, name, state) when name in @upper_classes do  
    {:ok, state}
  end

  def handle_event(:end_element, name, state) do
    {tuples_inner,[element_tuple|rest_tuples]}= Enum.split_while(state, fn {x,_} -> x !=name end)
    
    ttuple=
      tuples_inner
      |>Enum.reduce([],fn {_,tuple} , acc -> [tuple|acc] end)
      |>Map.new
      |>fix_new_tuple(element_tuple,name)

      {:ok, [ttuple|rest_tuples]}
  end

  def fix_new_tuple(map_inner,{tagname,[]},tagname) do
    {tagname,{tagname,map_inner}}
  end
  def fix_new_tuple(map_inner,{tagname,{key,attrmap}},tagname) when is_map(attrmap) do
    {tagname,{key,Map.merge(attrmap,map_inner)}}
  end
  

  def parse_attributes(attributes) do
    Map.new(attributes)
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