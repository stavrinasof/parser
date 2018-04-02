defmodule Http do
  @base_url "http://varnishcontapi.stoiximan.eu/content_api"

  def get_inplay_schedule(live) do
    http_response =
      live
      |> inplay_schedule_url
      |> HTTPoison.get()
      |> handle_response

    case http_response do
      {:ok, body} -> EventsParser.parse_events(body)
      {:error, msg} -> IO.inspect(msg)
    end
  end

  def get_inplay_event_detail(event_id) do
    http_response =
      event_id
      |> inplay_event_detail_url
      |> HTTPoison.get()
      |> handle_response

    case http_response do
      {:ok, body} ->    EventsParser.parse_event(body)
      {:error, msg} ->  {:error, msg}
    end
  end

  defp inplay_schedule_url(live) do
    "#{@base_url}?key=get_inplay_schedule&lang=el&is_inplay=#{live}"
  end

  defp inplay_event_detail_url(event_id) do
    "#{@base_url}?key=get_inplay_event_detail&lang=el&ev_id=#{event_id}" |> IO.inspect()
  end

  defp handle_response({:ok, %{status_code: 200, body: body}}) do
    {:ok, body}
  end

  defp handle_response({_, %{status_code: status, body: body}}) do
    {:error, "Error #{status} returned"}
  end
end
