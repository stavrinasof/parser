defmodule Benchmark do
  def start() do

    xml = File.read!("test/bench.xml")

    xml2 = File.read!("test/bench2.xml")


    map1 = XmlToMap.naive_map xml
    map1_attr = XmlToMapOrderInAttr.naive_map xml
    map1_key = XmlToMapOrderInKey.naive_map xml 
    map1_ch = XmlToMapOrderInAttr.naive_map xml
    {:ok, map1_saxy} =  XmlToMap.Saxy.parse xml
    Benchee.run(%{
      "No order"    => fn -> XmlToMap.naive_map xml end,
      "No order, chars insted of strings" => fn -> XmlToMapChars.naive_map xml end,
      "MapDiff No order, chars insted of strings" => fn -> map2 = XmlToMapChars.naive_map xml2 
                                                          MapDiff.diffs(map1, map2) end,
      "No order, Mapdiff" => fn -> map2 = XmlToMap.naive_map xml2
                                   MapDiff.diffs(map1_ch, map2) end,                                  
      "order in attributes" => fn -> XmlToMapOrderInAttr.naive_map xml end,
      "order in attributes, Mapdiff" => fn -> map2 = XmlToMapOrderInAttr.naive_map xml2
                                   MapDiffOrderInAttr.diffs(map1_attr, map2) end, 
      "order in key" => fn -> XmlToMapOrderInKey.naive_map xml end,
      "order in key, Mapdiff" => fn -> map2 = XmlToMapOrderInKey.naive_map xml2
                                   MapDiffOrderInKey.diffs(map1_key, map2) end, 
      "order with list" => fn -> XmlToMapListed.naive_map xml end,
      "Sax parser" => fn -> XmlToMapSax.saxmap xml end,
      "SAXY parser" => fn -> XmlToMap.Saxy.parse xml end,
      "MAPDIFF ,SAXY parser" => fn -> {:ok, map2_saxy}=XmlToMap.Saxy.parse xml2
                                MapDiffSaxy.diff(map1_saxy, map2_saxy) end,
    },
      formatters: [
        Benchee.Formatters.HTML,
        Benchee.Formatters.Console
      ], 
      formatter_options: [auto_open: false]
    )
  end
end

Benchmark.start