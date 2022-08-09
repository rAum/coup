defmodule CoupGame.Game.StateTest do
  use ExUnit.Case, async: true
  alias CoupGame.Game.State


  test "Fail when wrong number of players" do
    assert State.new([]) == :error
    assert State.new(["a"]) == :error
    assert State.new("Bad") == :error
    assert State.new(Enum.into(1..8, [])) == :error
  end

  test "Work when valid number of players" do
    for player_count <- 2..7 do
      players = Enum.into(1..player_count, [])
      assert %State{players:  ^players} = State.new(players)
    end
  end

  test "Each player starts with two coins" do
    players = [1, 2, 3]
    assert %State{public_state: %{ coins: coins}} = State.new(players)
    assert coins
    |> Map.values()
    |> Enum.all?(fn n -> n == 2 end)
  end

  test "Each player starts with two cards and rest is in court deck" do
    for player_count <- 2..7 do
      players = Enum.into(1..player_count, [])
      assert %State{priv_state: %{ hands: hands, court: court_deck}} = State.new(players)
      assert hands
      |> Map.values()
      |> Enum.all?(fn cards -> length(cards) == 2 end)

      n_court_deck = length(court_deck)
      assert  ^n_court_deck = 3 * 5 - length(players) * 2
    end
  end
end
