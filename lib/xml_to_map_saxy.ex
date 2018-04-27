defmodule XmlToMap.Saxy do
  def parse(xml) do
    
    # xml = String.replace(xml, ~r/\sxmlns=\".*\"/, "", global: false)
    # {:ok, xml} = :file.read_file("test/test.xml") 
    Saxy.parse_string(xml, EventHandler, [])
    # stream = File.stream!("test/test.xml")
    # Saxy.parse_stream(stream, EventHandler, [])

  end
end