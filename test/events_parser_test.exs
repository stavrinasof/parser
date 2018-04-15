defmodule EventsParserTest do
  use ExUnit.Case

  test "Check number of ev_id occurences" do
    {:ok, xml} = :file.read_file("test/xml_files/liveevents.xml")
    assert length(EventsParser.parse_events(xml)) == 15
    
  end

  test "check if naive_map has correct structure and certain key-value is correct" do
    {:ok, xml} = :file.read_file("test/xml_files/tennisevent.xml")
    map = EventsParser.parse_event(xml)

    pl1_id =
      get_in(map, [
        'Ev',
        'Incidents',
        {'Incident', '101687325'},
        'player1_id'
      ])

    assert pl1_id == '1005838'
  end
end
