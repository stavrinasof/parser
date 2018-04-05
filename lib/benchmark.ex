defmodule Benchmark do
  def start() do

    xml = File.read!("test/eventdetails.xml")

    Benchee.run(%{
      "no order"    => fn -> XmlToMap.naive_map xml end,
      "order in attributes" => fn -> XmlToMapOrderInAttr.naive_map xml end,
      "order in key" => fn -> XmlToMapOrderInKey.naive_map xml end,
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