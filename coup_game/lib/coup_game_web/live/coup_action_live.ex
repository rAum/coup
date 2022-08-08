defmodule CoupGameWeb.Live.CoupActionLive do
  use Phoenix.LiveComponent

  defp lookup_player_name(user_id) do
    [{_, name}] = CoupGame.Game.PlayerNames.lookup(user_id)
    name
  end

  defp users_to_attack(players, my_id) do
    players
    |> Map.filter(fn {key, _} -> key != my_id end)
  end
end
