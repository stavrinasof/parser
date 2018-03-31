defmodule Http do

    @base_url "http://varnishcontapi.stoiximan.eu/content_api"

def get_events(live) do
    http_response=
    live
    |> events_url
    |> IO.inspect
    |> HTTPoison.get
    |> handle_response

    case http_response do
        {:ok, body}     -> EventsParser.parse_events(body)
        {:error, msg}   -> IO.inspect msg
    end
end

def get_event_data(event_id) do
    http_response=
    event_id
    |> event_url
    |> HTTPoison.get
    |> handle_response

    case http_response do
    {:ok, body}     -> EventsParser.parse_event(body)
    {:error, msg}   -> IO.inspect msg
    end
end

def events_url(live) do
    "#{@base_url}?key=get_inplay_schedule&lang=el&is_inplay=#{live}"
end

def event_url(event_id) do
    "#{@base_url}?key=get_inplay_event_detail&lang=el&ev_id=#{event_id}"
end

def handle_response({ :ok, %{status_code: 200, body: body}}) do
    { :ok, body }
end

def handle_response({ _, %{status_code: status, body: body}}) do
    { :error, "Error #{status} returned" }
end

end
