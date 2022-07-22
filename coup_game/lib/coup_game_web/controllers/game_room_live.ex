defmodule CoupGameWeb.GameRoomLive do
  use CoupGameWeb, :live_view
  use Phoenix.Presence,
    otp_app: :room_presence,
    pubsub_server: CoupGame.PubSub

  require Logger

  @impl true
  def mount(%{"id" => room_id}, session, socket) do
    Logger.info("Mounting room " <> room_id)
    Logger.info("Session: #{inspect(session)}")

    # to track presence, we have to subscribe
    topic = room_id
    username = MnemonicSlugs.generate_slug()
    if connected?(socket) do
      CoupGameWeb.Endpoint.subscribe(topic)
      # self().track(self(), topic, %{
      #    online_at: inspect(System.system_time(:second)),
      # })
    end

    {:ok, assign(socket, room_id: room_id, username: username, user_list: [] )}
  end

  @impl true
  def render(assigns) do
    Logger.info("#{assigns.username} ---- #{inspect(assigns)}")
    # <h1><%= gettext "Welcome to %{assigns.room}!", name: "Coup Game" %></h1>
    ~H"""
    <section class="phx-hero">
    <p>Wait for other players to join. There is a need to have 2-5 players</p>
    <div id="player-list">
    <ul>
    <li>Me (<%= assigns.username %>)</li>
    </ul>
    </div>
    <button>Start game</button>
    </section>
    """
  end
end
