defmodule MapDiffTest do
  use ExUnit.Case

  @map_v1 %{
    "Sport" => %{
      "allow_cash_out" => "Y", "disporder" => "1",
       "name" => "Soccer", "sport_code" => "FOOT"
    },
    "Teams" => %{
      {"Team", "114960"} => %{
        "name" => "Oakleigh Cannons", "short_name" => "Oakleigh Cannons",
        "team_id" => "114960", "team_order" => "1"
      },
      {"Team", "118360"} => %{
        "name" => "Eastern Lions","short_name" => "Eastern Lions",
        "team_id" => "118360","team_order" => "0"
      },
      {"Team", "222666"} => %{"name" => "last value"}
    }
  }

  @map_v2 %{
    "Sport" => %{
      "allow_cash_out" => "N", "disporder" => "1",
       "name" => "Soccer", "sport_code" => "FOOT"
    },
    "Teams" => %{
      {"Team", "114960"} => %{
        "name" => "Oakleigh Cannons", "short_name" => "OakleighCannons",
        "team_id" => "114960", "team_order" => "1"
      },
      {"Team", "118360"} => %{
        "name" => "Eastern Lions","short_name" => "Eastern Lions",
        "team_id" => "118360","team_order" => "0"
      }
    }
  }

  test "delete nested key value" do
    assert MapDiff.delete_in(@map_v1, ["team_order", {"Team", "114960"}, "Teams"])
           |> get_in(["Teams", {"Team", "114960"}, "team_order"]) == nil
  end

  test "delete in doesn't leave trace" do
    assert MapDiff.delete_in(@map_v1, ["name", {"Team", "222666"}, "Teams"])
           |> Map.get("Teams")
           |> Map.has_key?({"Team", "222666"}) == false
  end

  test "values changed" do
    changes =MapDiff.diffs(@map_v1, @map_v2)
              |>elem(0)
              |>Map.get(:changes)

    assert length(Map.keys(changes))==2
    assert Map.has_key?(changes, ["Teams", {"Team", "114960"}, "short_name"]) ==true
    assert Map.get(changes,["Sport", "allow_cash_out"] ) == "N"
  end

  test "keys doesn't exist " do
    changes =MapDiff.diffs(@map_v1, @map_v2)
              |>elem(0)
              |>Map.get(:key_doesnt_exist)

    assert changes == %{}
    changes2 =MapDiff.diffs(@map_v2, @map_v1)
            |>elem(0)
            |>Map.get(:key_doesnt_exist)
    assert changes2 != %{}
    assert Map.get(changes2,["Teams", {"Team", "222666"}]) !=nil
    assert Map.get(changes2,["Sport"]) ==nil
  end

  test "rest of map_a" do
    map_a_rest =MapDiff.diffs(@map_v1, @map_v2)
              |>elem(1)

    assert is_map(map_a_rest) ==true
    assert Map.keys(map_a_rest) == ["Teams"]
    assert get_in(map_a_rest, ["Teams",{"Team", "222666"},"name"]) =="last value"
  end
end
