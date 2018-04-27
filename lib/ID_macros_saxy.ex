defmodule ID_Macros_Saxy do
  @ids [
    {"Mkt", "mkt_id"},
    {"Seln", "seln_id"},
    {"Incident", "incident_id"},
    {"Team", "team_id"},
    {"PeriodScore", "period"},
    {"Inplay", "inplay_period_num"},
    {"Player", "player_id"},
    {"EvDetail", "br_match_id"},
    {"Participant", "full_name"},
    {"Score", "name"},
    {"MatchStatus", "status_code"},
    # {"Price", "prc_type"},
    {"InplayDetail", "period_start"},
    {"MatchStat", "name"},
    {"Stat", "name"}
  ]

  defmacro not_in_list() do
    tagname = Macro.var(:tagname, __MODULE__)

    quote do
      def do_find_id_from_attributes(_, unquote(tagname)) do
        unquote(nil)
      end
    end
  end

  defmacro in_list() do
    attrvalue = Macro.var(:attrvalue, __MODULE__)

    @ids
    |> Enum.map(fn {tagname, attrname} ->
      quote do
        def do_find_id_from_attributes({unquote(attrname), unquote(attrvalue)}, unquote(tagname)) do
          a = unquote(tagname)
          {a, unquote(attrvalue)}
        end
      end
    end)
  end
end
