defmodule CoupGameWeb.PlayerChannel do
  use CoupGameWeb, :channel
  alias CoupGameWeb.GameRoomLive
  require Logger

  @impl true
  def join(topic, _params, socket) do
    send(self(), :after_join)
    user_id = UUID.uuid4()
    Logger.warn("User joined #{user_id} #{topic}")
    {:ok, assign(socket, :user_id, user_id)}
  end

  @impl true
  def handle_info(:after_join, socket) do
    {:_ok, _} = GameRoomLive.track(socket, socket.assigns.user_id, %{
      online_at: inspect(System.system_time(:second))
    })

    push(socket, "presence_state", GameRoomLive.list(socket))
    Logger.info("User joined %{socket.assigns.user_id}")
    {:noreply, socket}
  end
end
