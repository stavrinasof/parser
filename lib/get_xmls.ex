defmodule GetXmls do
    
    def get_xml_for_all_sports() do
        get_sports_url
        |> HTTPoison.get()
        |> handle_response
        |> get_sports
        |> Enum.each( &get_events_for_sport_url(&1)
                        |> HTTPoison.get()
                        |> handle_response
                        |> get_an_event_id_for_this_sport
                        |> fetch_xml(&1)
                    )
    end

    def remainings_xmls() do
        list_with_all_sports =
        get_sports_url
        |> HTTPoison.get()
        |> handle_response
        |> get_sports
        |> Enum.sort
        
        exists_xmls=
        Path.wildcard("test/xml_files_for_all_sports/*.xml") 
        |> Enum.map(&Path.basename(&1,".xml")) 
        |> Enum.sort     

         exists_xmls -- list_with_all_sports

    end

    defp fetch_xml([], sport), do: IO.inspect "no events for #{sport}"
    defp fetch_xml(ev_id_list, sport) do
        http_response = ev_id_list
        |> List.first
        |> inplay_event_detail_url
        |> HTTPoison.get()
        |> handle_response
        
        case http_response do
            {:ok, body}   -> File.write("test/xml_files_for_all_sports/#{sport}.xml", body)
            {:error, msg} -> {:error, msg}
        end
    end

    defp get_an_event_id_for_this_sport({:ok, body}), do: parse_body_event_ids(body)
    defp get_an_event_id_for_this_sport({:error, msg}), do: {:error, msg}

    defp get_sports({:ok, body}), do: parse_body_sport_codes(body)
    defp get_sports({:error, msg}), do: {:error, msg}

    defp get_sports_url() do
        "http://varnishcontapi.stoiximan.eu/content_api?key=get_sports&lang=el"
    end

    defp get_events_for_sport_url(sport) do
        "http://varnishcontapi.stoiximan.eu/content_api?key=get_events_for_sport&lang=el&sport_code=#{sport}"
    end

    defp inplay_event_detail_url(event_id) do
        "http://varnishcontapi.stoiximan.eu/content_api?key=get_inplay_event_detail&lang=el&ev_id=#{event_id}"
    end

    defp handle_response({:ok, %{status_code: 200, body: body}}) do
        {:ok, body}
    end

    defp handle_response({_, %{status_code: status, body: _}}) do
        {:error, "Error #{status} returned"}
    end


    def parse_body_event_ids(body) do
         :erlsom.parse_sax(body, [], fn xmline, acc -> do_get_event_ids(xmline, acc) end)
         |> elem(1)
    end

    def do_get_event_ids({:startElement, _, 'Ev', _, list}, acc) do
        {_, 'ev_id', _, _, evid} = Enum.at(list, 1)
        [evid | acc]
    end
    def do_get_event_ids(_, acc), do: acc


    def parse_body_sport_codes(body) do
         :erlsom.parse_sax(body, [], fn xmline, acc -> do_get_sport_codes(xmline, acc) end)
         |> elem(1)
    end

    def do_get_sport_codes({:startElement, _, 'Sport', _, list}, acc) do
        {_, 'sport_code', _, _, sport_code} = Enum.at(list, 3)
        [sport_code | acc]
    end
    def do_get_sport_codes(_, acc), do: acc
end