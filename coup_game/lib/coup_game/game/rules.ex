defmodule CoupGame.Game.Rules do
  alias CoupGame.Game.State
  alias CoupGame.Game.Action

def try_action(%Action{:origin => player_id} = action, %State{}=state) do
  execute_action(action, state,  is_turn?(player_id, state))
end

def is_turn?(player_id, %State{:public_state => %{:turn_order => turn_order, :turn => turn}}) do
  turn_order[player_id] == turn
end

defp execute_action(action, state, true), do: {:ok, exe(action, state)}
defp execute_action(_, state, false), do: {:error, state}

defp exe(%Action{:origin => player_id, :type => :tax}, %State{}=state) do
  new_coins = state.public_state.coins
    |> Map.update(player_id, 0, &(&1 + 1))
    pub_state = %{state.public_state | :coins => new_coins}
    %{next_turn(state) | public_state: pub_state}
end

defp exe(_, state) do
  state
end

defp next_turn(%State{} = state) do
  n = state.players |> Enum.count()
  new_public = %{state.public_state | turn: rem(state.public_state.turn + 1, n)}
  %{state | public_state: new_public}
end

end
