defmodule Profiler do
  import ExProf.Macro

  @doc "analyze with profile macro"
  def do_analyze do
    {:ok, xml} = :file.read_file("test/bench.xml")
    map1 =  EventsParser.parse_event(xml)
    profile do
        {:ok, xml} = :file.read_file("test/bench2.xml")
        map2 =  EventsParser.parse_event(xml)
        MapDiff.diffs(map1, map1)
    end
  end

  @doc "get analysis records and sum them up"
  def run do
    {records, _block_result} = do_analyze
    total_percent = Enum.reduce(records, 0.0, &(&1.percent + &2))
    IO.inspect "total = #{total_percent}"
  end
end