defmodule XmlParser do
    def get_event_ids do
    {:ok, xml} = :file.read_file("test/liveevents.xml")
    {:ok, events, []} = :erlsom.parse_sax(xml,[],fn(xmline, acc) -> do_get_event_ids(xmline, acc) end)
    events
  end

  def do_get_event_ids({:startElement, _, 'Ev', _, list}, acc) do
    {_, 'ev_id', _, _, evid} = Enum.at(list, 1)
    [evid | acc]
  end

  def do_get_event_ids(_, acc), do: acc

  def with_xmltomap do
    # file = File.read! "test/tennisevent.xml"
    # file = File.read!("test/liveevents.xml")
    # file = File.read!("test/politics_event.xml")

    File.read!("test/small.xml")
    |> XmlToMap.naive_map

  end
end
