defmodule EventsParser do
  def parse_events(body) do
    {:ok, events, _} =
      :erlsom.parse_sax(body, [], fn xmline, acc -> do_get_event_ids(xmline, acc) end)

    events
  end

  def do_get_event_ids({:startElement, _, 'Ev', _, list}, acc) do
    {_, 'ev_id', _, _, evid} = Enum.at(list, 1)
    [evid | acc]
  end

  def do_get_event_ids(_, acc), do: acc

  def parse_event(body) do
    body
    |> XmlToMap.naive_map()
  end
end
