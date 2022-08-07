defmodule CoupGameWeb.Components.PlayerList do
  use Phoenix.Component

  defp lookup_player_name(user_id) do
    [{_, name}] = CoupGame.Game.PlayerNames.lookup(user_id)
    name
  end

  def render(assigns) do
    ~H"""
    <div id="player-list" class="container p-2 min-h-max w-64 border-blue-400">
    <ul class="list-none list-outside text-xs align-middle border-blue-400">
    <%= for user <- @user_list do %>
    <li class="[&:nth-child(odd)]:bg-slate-500 bg-slate-400 p-1">
    ➡️&nbsp;
    <%=
    me_name = @user_id
    case user do
        ^me_name -> lookup_player_name(user) <> " (it's me!)"
        _ -> lookup_player_name(user)
      end %>
    </li>
    <% end %>
    </ul>
    </div>
    """
  end
end
