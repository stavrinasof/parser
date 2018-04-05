defmodule XmlToMaptTest do
  use ExUnit.Case

  @selection {'Seln',
              [
                {'seln_sort', 'H'},
                {'disporder', '1'},
                {'team_id', '118360'},
                {'seln_id', '484026793'},
                {'name', 'Eastern Lions'},
                {'status', 'A'}
              ],
              [
                {'Price',
                 [
                   {'last_change', '2018-03-28T09:56:47'},
                   {'us_prc', '+3300'},
                   {'frac_prc', '33/1'},
                   {'bet_ref', 'NDg0MDI2NzkzOjMzLzE6OjA'},
                   {'dec_prc', '34.00'},
                   {'prc_type', 'LP'}
                 ], []}
              ]}

  @notes {'Notes', [], ['Pitchers: Foltynewicz (ATL) - Scherzer (WSH)']}
  @market {'Mkt',[
      {'status', 'A'},
      {'displayed', 'Y'},
      {'mkt_id', '118360'}
    ],
    [
      @selection,
      {'Seln',
              [
                {'seln_sort', 'H'},
                {'disporder', '1'},
                {'team_id', '118360'},
                {'seln_id', '484026786'},
                {'name', 'Eastern Lions'},
                {'status', 'A'}
              ],
              [
                {'Price',
                 [
                   {'last_change', '2018-03-28T09:56:47'},
                   {'us_prc', '+3300'},
                   {'frac_prc', '33/1'},
                   {'bet_ref', 'NDg0MDI2NzkzOjMzLzE6OjA'},
                   {'dec_prc', '34.50'},
                   {'prc_type', 'LP'}
                 ], []}
              ]}
    ]
  }

  test "do parse attributes into a map" do
    {_tagname, attributes, _content} = @selection
    attr_map = XmlToMap.do_parse_attributes(attributes)
    assert length(Map.keys(attr_map)) == 6
    assert Map.get(attr_map, "disporder") == "1"
  end

  test "parse tuple returns map" do
    seln_map = XmlToMap.parse(@selection,0)
    seln_value_map = Map.get(seln_map, {"Seln", "484026793"})

    assert is_map(seln_map) == true
    assert is_map(Map.get(seln_value_map, {"Price", "LP"})) == true
  end

  test "parse notes" do
    notes_map = XmlToMap.parse(@notes,0)
    assert is_map(notes_map) == true
    assert Map.keys(notes_map) == ["Notes"]
  end

  test "parse turple with tuple content" do
    seln_map = XmlToMap.parse(@selection,0)
    seln_value_map = Map.get(seln_map, {"Seln", "484026793"})

    assert length(Map.keys(seln_value_map)) == 8   #7+1 for order attribute
    assert Map.get(seln_value_map, {"Price", "LP"}) != nil
  end


  test "order in attributes" do
    market_map = XmlToMap.parse(@market,0)
    #IO.inspect market_map
    seln_value_map1 = get_in(market_map, [{"Mkt", "118360"},{"Seln", "484026793"}])
    seln_value_map2 = get_in(market_map, [{"Mkt", "118360"},{"Seln", "484026786"}])

    assert Map.get(seln_value_map1, "order") == "0"
    assert Map.get(seln_value_map2, "order") == "1"
  end
end
