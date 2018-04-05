defmodule Benchmark do
  def start() do

    xml = File.read!("test/eventdetails.xml")

    Benchee.run(%{
      "order in key"    => fn -> XmlToMap.naive_map xml end,
      "order in key 2" => fn -> XmlToMap.naive_map xml end
    },
      formatters: [
        Benchee.Formatters.HTML,
        Benchee.Formatters.Console
      ]
      # override defaults
      #, formatter_options: [html: [file: "output/my.html", auto_open: false]]
    )
  end
end