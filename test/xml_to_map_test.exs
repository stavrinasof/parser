defmodule XmlToMaptTest do
  use ExUnit.Case

  @sporttuple {'Sport',
    [
      {'disporder', '1'},
      {'name', 'Soccer'},
      {'allow_cash_out', 'Y'},
      {'sport_code', 'FOOT'}
    ],[]}

  test "find id from attributes" do
    {tagname,attributes,_content}= @sporttuple
    #key  = find_id_from_attributes(tagname,attributes)
    assert XmlToMap.find_id_from_attributes(tagname,attributes) == {"Sport","FOOT"}
  end

  test "find id from empty attributes" do
    {tagname,_attributes,_content}= @sporttuple
    #key  = find_id_from_attributes(tagname,attributes)
    assert XmlToMap.find_id_from_attributes(tagname,[]) == {"Sport"}
  end


  test "do parse attributes into a map" do
    {tagname,attributes,_content}= @sporttuple
    attr_map = XmlToMap.do_parse_attributes(attributes)
    #assert Map.get(attr_map ,"disorder") == "1"
    #assert length( Map.keys(attr_map )) == 4
  end
end
