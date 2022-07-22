defmodule CoupGameWeb.GameRoomLive do
  use CoupGameWeb, :live_view
  alias CoupGameWeb.PlayerPresence
  require Logger

  @impl true
  def mount(%{"id" => room_id}, _session, socket) do
    Logger.info("Mounting room " <> room_id)

    # to track presence, we have to subscribe
    username = MnemonicSlugs.generate_slug()
    if connected?(socket) do
      CoupGameWeb.Endpoint.subscribe(room_id)
      PlayerPresence.track(self(), room_id, username, %{
          online_at: inspect(System.system_time(:second)),
      })
    end

    user_list = PlayerPresence.list(room_id) |> Map.keys()
    {:ok, assign(socket, room_id: room_id, username: username, user_list: user_list)}
  end

  @impl true
  def handle_info(%{event: "presence_diff"}, socket) do
    user_list = PlayerPresence.list(socket.assigns.room_id) |> Map.keys()
    socket = assign(socket, user_list: user_list)
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    Logger.info("#{assigns.username} ---- #{inspect(assigns)}")
    # <h1><%= gettext "Welcome to %{assigns.room}!", name: "Coup Game" %></h1>
    ~H"""
    <section class="phx-hero">
    <p>Wait for other players to join. There is a need to have 2-5 players</p>
    <p>Currently we have <%= length(@user_list) %>/5 players.</p>
    <div id="player-list">
    <ul>
    <%= for user <- @user_list do %>
    <li><%=
    me_name = @username
    case user do
        ^me_name -> user <> " (it's me!)"
        _ -> user
      end %></li>
    <% end %>
    </ul>
    </div>
    <%=
      user_count = @user_list |> length
      if user_count >= 2 and user_count <= 5 do%>
    <button>Start game</button>
    <% end %>
    </section>
    """
  end
end
