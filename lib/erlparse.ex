defmodule Erlparse do
  #  import SweetXml
  #   require Record
  #   import Record, only: [defrecord: 2, extract: 2]

  #   {:ok,xml} =  :file.read_file("test/file.xml")
  #   :erlsom.write_xsd_hrl_file("test/fileschema.xsd", "test/records.hrl")

  #   xml_path = Path.join([__DIR__, "../test/", "records.hrl"])
  #   defrecord :current_observation,  extract(:Sport, from: xml_path)

  #   client = [{"User-agent", "Example Elixir Project"}]
  #   options = [follow_redirect: true]
  #   airport_code = "RDU"
  #   HTTPoison.start
  #   %HTTPoison.Response{body: body}= HTTPoison.get!("http://w1.weather.gov/xml/current_obs/KRDU.xml")
  #  schema_url = body |> xpath(
  #    ~x"//current_observation/@xsi:noNamespaceSchemaLocation")
  #  %HTTPoison.Response{body: schema_body} = HTTPoison.get!(
  #    schema_url, client, options)
  #  File.write!(Path.join(__DIR__, "current_observation.xsd"), schema_body)


  # def erlsom_transform(data = current_observation()), do:
  #   Enum.into(current_observation(data), Map.new, &_transform_value/1)
  # def erlsom_transform(data = [first | _rest]) when is_integer(first), do:
  #   List.to_string(data)
  # def erlsom_transform(:undefined), do: nil
  # def erlsom_transform(data), do: data

  # defp _transform_value({k, v}), do: {k, erlsom_transform(v)}


  # def handle_body do
  #   # {:ok, data, _rest} = :erlsom.scan(body, @xsdModel)

  #   {:ok,model} =:erlsom.compile_xsd_file("test/fileschema.xsd")
  #   {:ok,se,_} = :erlsom.scan_file("test/file.xml",model)
  #   erlsom_transform(se)
  # end

  def hello do
    {:ok,xml} =  :file.read_file("test/liveevents.xml")
    {:ok,events,[]} = :erlsom.parse_sax(xml,[],fn(xmline, acc) ->  do_parse(xmline,acc) end)
    events
  end


  def do_parse({:startElement, _, 'Ev', _,list},acc) do
    list |> IO.inspect
    {_,'ev_id',_,_,evid} = Enum.at(list,1)
    [evid |acc]
  end
  def do_parse(_,acc) ,do: acc

  def with_xmltomap(file) do
    # file = File.read! "test/tennisevent.xml"
    file = File.read! "test/liveevents.xml"
    map = ToMap_V2.naive_map(file)

    #Meta einai lista apo maps pou mporoume na diatrexoume kai na exoume ola ta key-value pairs analogws pws mas volevei

  end

  def get_lives do
    %HTTPoison.Response{status_code: stat, headers: head, body: xml} = HTTPoison.get!("http://varnishcontapi.stoiximan.eu/content_api?key=get_inplay_schedule&lang=en&is_inplay=Y")
    xml
  end

  def get_events_for_sport(sport) do
    %HTTPoison.Response{status_code: stat, headers: head, body: xml} = HTTPoison.get!("http://varnishcontapi.stoiximan.eu/content_api?key=get_events_for_sport&sport_code="<>sport)
    xml
  end


end
