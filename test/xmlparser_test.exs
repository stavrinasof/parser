defmodule XmlParserTest do
  use ExUnit.Case
  doctest XmlParser

  test "Check number of ev_id occurences" do
    event_ids = XmlParser.get_event_ids
    {:ok, xml} = :file.read_file("test/liveevents.xml")
    Enum.all?(event_ids, fn x -> String.contains?(xml, to_string(x))end)
  end

  test "check if naive_map has correct structure and certain key-value is correct" do
    
    map = XmlParser.with_xmltomap
    pl1_id = get_in(map, [{"ContentAPI"}, {"Sport", "TENN"}, {"SBClass", "10009"}, {"SBType", "17632"}, {"Ev", "1680638"}, {"Incidents"}, {"Incident", "101687325"}, "player1_id"])

    assert pl1_id=="1005838"
  end
  # test "greets the world" do
  #   assert XmlParser.hello() == :world
  # end
end
