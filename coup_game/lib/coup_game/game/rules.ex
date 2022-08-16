defmodule CoupGame.Game.Rules do
  alias CoupGame.Game.State
  alias CoupGame.Game.Action

@spec try_action(Action.t(), State.t()) :: {:ok | :error, State.t()}
def try_action(%Action{:origin => player_id} = action, %State{}=state) do
  execute_action(action, state,  can_do_action?(player_id, state))
end

@spec is_turn?(any, State.t()) :: boolean
def is_turn?(player_id, %State{:turn_order => turn_order, :turn => turn}) do
  turn_order[player_id] == turn
end

@spec can_do_action?(any, State.t()) :: boolean
def can_do_action?(player_id, state) do
  is_turn?(player_id, state) and not is_blocked?(player_id, state) and not is_dead?(player_id, state)
end

@spec is_blocked?(any, State.t()) :: boolean
def is_blocked?(player_id, %State{:game_stack => [{_, other_id} | _]}), do: player_id != other_id
def is_blocked?(_, _), do: false

@spec is_dead?(any, State.t()) :: boolean
def is_dead?(player_id, state) do
  length(state.hands[player_id]) <= 0
end

@spec execute_action(Action.t(), State.t(), boolean) :: {:ok | :error, State.t()}
defp execute_action(action, state, true), do: exe(action, state)
defp execute_action(_, state, false), do: {:error, state}

@spec exe(Action.t(), State.t()) :: {:ok | :error, State.t() }
defp exe(%Action{:origin => player_id, :type => :tax}, %State{}=state) do
  new_coins = state.coins
    |> Map.update(player_id, 0, &(&1 + 1))
    {:ok, %{next_turn(state) |  :coins => new_coins}}
end

defp exe(%Action{:origin => player_id, :type => :card_pick, :payload => card_id}, %State{hands: hands} = state) do
  new_hand = Enum.filter(hands[player_id], fn {_, v} -> v == card_id end)
  {:ok, %{state | hands: %{hands | player_id => new_hand} }}
end

defp exe(%Action{:origin => player_id, :type => :coup, :target => target_id}, %State{} = state) do
  cost = 7

  not_self = player_id != target_id
  can_pay = state.coins[player_id] > cost
  target_lives = length(state.hands[player_id])

  if not_self and can_pay do
    case target_lives do
      1 -> # auto kill
        new_hands = Map.update(state.hands, player_id, [], fn _ -> [] end)
        {:ok, %{state | hands: new_hands }}
      2 -> # player selects who to kill
        coins = Map.update(state.coins, player_id, 0, &(&1 - cost))
        {:ok, %{state | game_stack: [{:coup, target_id} | state.game_stack], coins: coins}}
      _ -> # cannot kill
        {:error, state}
    end
  else
    {:error, state}
  end
end

defp exe(_, state) do
  {:ok, state}
end

defp next_turn(%State{} = state) do
  n = state.players |> Enum.count()
  %{state | turn: rem(state.turn + 1, n)}
end

end
