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

  test "do parse attributes into a map" do
    {_tagname, attributes, _content} = @selection
    attr_map = XmlToMap.do_parse_attributes(attributes)
    assert length(Map.keys(attr_map)) == 6
    assert Map.get(attr_map, "disporder") == "1"
  end

  test "parse tuple returns tuple" do
    seln_map = XmlToMap.parse(@selection)
    assert is_tuple(seln_map) == true
  end

  test "parse notes" do
    notes_tuple = XmlToMap.parse(@notes)
    assert is_tuple(notes_tuple) == true
    assert elem(notes_tuple, 0) == "Notes"
  end

  test "parse turple with tuple content" do
    parsed_selection = XmlToMap.parse(@selection)
    selection_map = elem(parsed_selection, 1)

    assert length(Map.keys(selection_map)) == 7
    assert Map.get(selection_map, "Price") != nil
  end
end
