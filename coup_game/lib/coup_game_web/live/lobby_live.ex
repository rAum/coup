defmodule CoupGameWeb.LobbyLive do
  use CoupGameWeb, :live_view
  alias CoupGame.Game.PlayerNames
  require Logger


  @impl true
  def mount(_params, session, socket) do
    Logger.info("Mounting LobbyLive")
    user_id = session["user_id"]

    user_name = case PlayerNames.lookup(user_id) do
      [{_, user_name}] -> user_name
      _ ->
        slug = MnemonicSlugs.generate_slug()
        PlayerNames.add_update(user_id, slug)
        slug
    end

    {:ok, assign(socket, user_name: user_name, user_id: user_id)}
  end

  @impl true
  def handle_event("user-settings-change", change, socket) do
    new_name = String.trim(change["username"])
    socket =  case byte_size(new_name) do
      0 -> socket
      _ ->
        assign(socket, user_name: new_name)
        Logger.info("Changing name #{new_name}")
        PlayerNames.add_update(socket.assigns.user_id, new_name)
        socket
    end
    {:noreply, socket}
  end

  @impl true
  def handle_event("gen-random-room", _params, socket) do
    slug = "/room/join/" <> MnemonicSlugs.generate_slug(4)
    {:noreply, redirect(socket, to: slug)}
  end

  @impl true
  def handle_event("enter-room", _params, socket) do
    {:noreply, socket}
  end
end
