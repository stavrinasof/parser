defmodule ID_MacrosTest do
  use ExUnit.Case
  require ID_Macros

  ID_Macros.in_list()
  ID_Macros.not_in_list()

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

  test "find id from attributes" do
    {tagname, attributes, _content} = @selection
    assert XmlToMap.find_id_from_attributes(tagname, attributes) == {'Seln', '484026793'}
  end

  test "find id from empty attributes" do
    {tagname, _attributes, _content} = @notes
    assert XmlToMap.find_id_from_attributes(tagname, []) == 'Notes'
  end

  test "do find id from attribute in list" do
    tuple = do_find_id_from_attributes({'seln_id', '484026793'}, 'Seln')
    assert tuple == {'Seln', '484026793'}
  end

  test "do find id from attribute not in list" do
    tuple = do_find_id_from_attributes({'disporder', '1'}, 'Seln')
    assert tuple == nil
  end
end
