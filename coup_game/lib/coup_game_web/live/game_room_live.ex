defmodule CoupGameWeb.GameRoomLive do
  use CoupGameWeb, :live_view
  alias CoupGameWeb.PlayerPresence
  alias CoupGame.Game.PlayerNames
  require Logger

  @impl true
  def mount(%{"id" => room_id}, session, socket) do
    %{"user_id" => user_id} = session

    user_name = lookup_player_name(user_id)
    Logger.info("Mounting #{__MODULE__} #{room_id} for #{user_name}")

    if connected?(socket) do
      CoupGameWeb.Endpoint.subscribe(room_id)
      PlayerPresence.track(self(), room_id, user_id, %{
          online_at: inspect(System.system_time(:second)),
      })
    end

    user_list = PlayerPresence.list(room_id) |> Map.keys()
    {:ok, assign(socket, room_id: room_id, user_id: user_id, username: user_name, user_list: user_list)}
  end

  defp lookup_player_name(user_id) do
    [{_, name}] = PlayerNames.lookup(user_id)
    name
  end

  @impl true
  def handle_info(%{event: "presence_diff"}, socket) do
    user_list = PlayerPresence.list(socket.assigns.room_id)
    |> Map.keys()
    |> Enum.map(&lookup_player_name/1)

    socket = assign(socket, user_list: user_list)
    {:noreply, socket}
  end

end
