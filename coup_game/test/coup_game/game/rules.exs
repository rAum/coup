defmodule CoupGame.Game.RulesTest do
  use ExUnit.Case, async: true
  alias CoupGame.Game.{State, Action, Rules}

  test "only one player can do action" do
    players = Enum.into(1..3, [])
    state = State.new(players)

    pa = for p <- players do
      Rules.can_do_action?(p, state)
    end
    assert Enum.filter(pa, &(&1 == true)) |> length == 1
  end
end
