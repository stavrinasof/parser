defmodule XmlParserTest do
  use ExUnit.Case
  doctest XmlParser

  @list_with_maps [
    %{
      {"PeriodScore", "2"} => %{
        "period" => "2",
        "score_a" => "0",
        "score_b" => "1",
        "score_string" => "0-1"
      }
    },
    %{
      {"PeriodScore", "1"} => %{
        "period" => "1",
        "score_a" => "0",
        "score_b" => "1",
        "score_string" => "0-1"
      }
    }
  ]
  # after dynamic merge
  # %{
  #   {"PeriodScore", "1"} => %{
  #     "period" => "1",
  #     "score_a" => "0",
  #     "score_b" => "1",
  #     "score_string" => "0-1"
  #   },
  #   {"PeriodScore", "2"} => %{
  #     "period" => "2",
  #     "score_a" => "0",
  #     "score_b" => "1",
  #     "score_string" => "0-1"
  #   }
  # }
  @list_with_maps2 [
    %{{"Score"} => %{"name" => "current_set_games_won", "score_a" => "4", "score_b" => "4"}},
    %{{"Score"} => %{"name" => "is_server", "score_a" => "Y", "score_b" => "N"}},
    %{{"Score"} => %{"name" => "sets_won", "score_a" => "1", "score_b" => "1"}},
    %{{"Score"} => %{"name" => "set_2_games", "score_a" => "6", "score_b" => "1"}},
    %{{"Score"} => %{"name" => "set_1_games", "score_a" => "2", "score_b" => "6"}},
    %{{"Score"} => %{"name" => "current_game_score", "score_a" => "A", "score_b" => "40"}}
  ]
  # after dynamic merge
  # %{{"Scores"} => %{
  #     {"Score"} => [
  #       %{"name" => "current_game_score", "score_a" => "A", "score_b" => "40"},
  #       %{"name" => "set_1_games", "score_a" => "2", "score_b" => "6"},
  #       %{"name" => "set_2_games", "score_a" => "6", "score_b" => "1"},
  #       %{"name" => "sets_won", "score_a" => "1", "score_b" => "1"},
  #       %{"name" => "is_server", "score_a" => "Y", "score_b" => "N"},
  #       %{"name" => "current_set_games_won", "score_a" => "4", "score_b" => "4"}
  #     ]
  #   }
  # }

  test "Check number of ev_id occurences" do
    event_ids = XmlParser.get_event_ids()
    {:ok, xml} = :file.read_file("test/liveevents.xml")
    Enum.all?(event_ids, fn x -> String.contains?(xml, to_string(x)) end)
  end

  test "check if naive_map has correct structure and certain key-value is correct" do
    map = XmlParser.with_xmltomap()

    pl1_id =
      get_in(map, [
        {"ContentAPI"},
        {"Sport", "TENN"},
        {"SBClass", "10009"},
        {"SBType", "17632"},
        {"Ev", "1680638"},
        {"Incidents"},
        {"Incident", "101687325"},
        "player1_id"
      ])

    assert pl1_id == "1005838"
  end

  test "dynamic merge of list with maps (keyname, keyid)" do
    results =
      @list_with_maps
      |> Enum.reduce(%{}, &XmlToMap.dynamic_merge(&1, &2))

    assert @list_with_maps
           |> List.first()
           |> Map.keys()
           |> Enum.all?(&Enum.member?(Map.keys(results), &1)) == true

    assert length(Map.keys(results)) == 2
  end

  test "dynamic merge of list with maps (keyname)" do
    results =
      @list_with_maps2
      |> Enum.reduce(%{}, &XmlToMap.dynamic_merge(&1, &2))

    # all maps in the list have the same key
    assert @list_with_maps2
           |> Enum.map(fn m -> List.first(Map.keys(m)) end)
           |> Enum.dedup()
           |> length == 1

    # check the structure of the data
    assert results
           |> Map.values()
           |> is_list == true

    # check all the maps in the list have the same key
    assert results
           |> Map.values()
           |> List.first()
           |> Enum.map(fn m -> List.first(Map.keys(m)) end)
           |> Enum.dedup()
           |> length == 1
  end
end
