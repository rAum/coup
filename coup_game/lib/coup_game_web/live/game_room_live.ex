defmodule CoupGameWeb.GameRoomLive do
  use CoupGameWeb, :live_view
  alias CoupGameWeb.PlayerPresence
  alias CoupGame.Game.{Rooms, Room, PlayerNames}
  alias CoupGameWeb.Components.{Card, PlayerList}
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
    room_pid = Room.exists(room_id)
    {hand, public_state} = case room_pid do
      nil -> {[], %{}}
      pid ->
        {Room.get_player_hand(pid, user_id), Room.get_public_state(room_id)}
    end

    user_list = PlayerPresence.list(room_id) |> Map.keys()

    init_state = %{
      room_id: room_id,
      user_id: user_id,
      username: user_name,
      user_list: user_list,
      room_pid: room_pid,
      game_on: room_pid != nil,
      hand: hand,
      public_state: public_state,
      coup: false,
    }

    Logger.info("Mounting with state: #{inspect(init_state)}")
    {:ok, assign(socket, init_state)}
  end

  defp lookup_player_name(user_id) do
    [{_, name}] = PlayerNames.lookup(user_id)
    name
  end

  @impl true
  def handle_event("game_start", _st, socket) do
    if not socket.assigns.game_on do
      room_id = socket.assigns.room_id

      # todo: verify number of players

      case Rooms.start_child(room_id) do
        {:ok, room_pid} ->
          PlayerPresence.list(room_id)
          |> Map.keys()
          |> Enum.each(&Room.add_player(room_pid, &1))

          CoupGameWeb.Endpoint.broadcast(room_id, "game_start", %{room_pid: room_pid})

          {:error, {:already_started, room_pid}} ->
            Logger.warn("Room is already created.")
            CoupGameWeb.Endpoint.broadcast(room_id, "game_start", %{room_pid: room_pid})
            Logger.info(Room.log_state(socket.assigns.room_id))
          res -> Logger.error("Unexpected error: #{inspect(res)}")
      end
    end
    {:noreply, socket}
  end

  @impl true
  def handle_event("action", %{"type" => type}, socket) do
    Logger.info("Triggered action #{inspect(type)}")
    public_state = Room.get_public_state(socket.assigns.room_id)
    socket = if public_state.turn == public_state.turn_order[socket.assigns.user_id] do
      handle_action(type, socket)
    else
      socket
      |> put_flash(:error, "It's not your turn!")
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel_coup", _, socket) do
    {:noreply, assign(socket, coup: false)}
  end

  @impl true
  def handle_event("coup_exe", %{"id" => target}, socket) do
    Logger.info("COUP >>> #{target}")
    {:noreply, assign(socket, coup: false)}
  end

  defp handle_action("coup", socket) do
    if socket.assigns.public_state.coins[socket.assigns.user_id] < 3 do
      socket |> put_flash(:error, "Not enough coins to start a coup!")
    else
      socket = assign(socket, coup: true)
      Logger.info("Coup in progress")
      socket
    end
  end

  defp handle_action(type, socket) do
    Room.take_action(socket.assigns.room_id, socket.assigns.user_id, type)
    CoupGameWeb.Endpoint.broadcast(socket.assigns.room_id, "game_update", %{})
    socket
  end

  @impl true
  def handle_info(%{event: "presence_diff"}, socket) do
    user_list = PlayerPresence.list(socket.assigns.room_id)
    |> Map.keys()

    socket = assign(socket, user_list: user_list)
    {:noreply, socket}
  end

  @impl true
  def handle_info(%{event: "game_start", payload: %{room_pid: pid}}, socket) do
    Logger.info(">>> START GAME <<<")
    socket = assign(socket, game_on: true, room_pid: pid)
    Room.start_game(pid)
    socket = sync_socket_with_state(socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info(%{event: "game_update", payload: _payload}, socket) do
    Logger.info("~~~ game update ~~~")
    socket = sync_socket_with_state(socket)
    {:noreply, socket}
  end

  defp sync_socket_with_state(socket) do
    hand = Room.get_player_hand(socket.assigns.room_pid, socket.assigns.user_id)
    public = Room.get_public_state(socket.assigns.room_id)
    assign(socket, hand: hand, public_state: public)
  end

  #==================

  def players_state(assigns) do
    ~H"""
    <div id="public-status" class="min-h-max min-w-max">
    <ul class="list-none list-outside text-s align-middle border-blue-400">
    <%= for user <- @user_list do %>
    <li class="[&:nth-child(odd)]:bg-slate-500 bg-slate-400 p-1">
    <%=
    me_name = @user_id
    turn = @public_state.turn
    turn_tag = case @public_state.turn_order[user] do
      ^turn -> "♟️ "
      _ -> "  "
    end

    name = case user do
        ^me_name -> lookup_player_name(user) <> " (it's me!)"
        _ -> lookup_player_name(user)
      end
      turn_tag <> name
    %>
    <span>
    <%=
    n_coins = @public_state.coins[user]
    for _ <- 1..n_coins do
    %>🪙<% end %>
     [<%= n_coins %>/10 to ☠️]
    </span>
    </li>

    <% end %>
    </ul>
    <p>10 coins are required to perform unstopable assasination.</p>
    </div>
    """
  end

  def actions(assigns) do
    ~H"""
    <p class="">Card actions:</p>
    <ol>
    <li class="hover:bg-blue-800"><button phx-click="action" phx-value-type={:tax}>Duke - <strong>Tax</strong>: +3 coins.</button></li>
    <li class="hover:bg-blue-800"><button phx-click="action" phx-value-type={:assasin}>Assasin - <strong>Assasinate</strong>: -3 coins and launch assasination against another player.</button></li>
    <li class="hover:bg-blue-800"><button phx-click="action" phx-value-type={:steal}>Captain - <strong>Steal</strong>: +1 or +2 coins: steal from another player.</button></li>
    <li class="hover:bg-blue-800"><button phx-click="action" phx-value-type={:exchange}>Ambassador - <strong>Exchange</strong>: You can exchange (or not) up to 2 active cards with 2 random from the Court deck. Unselected go back to Court deck.</button></li>
    </ol>
    <p>Card counteractions:</p>
    <ol>
    <li class="hover:bg-blue-800"><button phx-click="counteraction" phx-value-type={:block_assasin}>Contessa - <strong>Block Assasination</strong>: if you are attacked by assasin, you fail the assasination attempt.</button></li>
    <li class="hover:bg-blue-800"><button phx-click="counteraction" phx-value-type={:block_steal}>Ambassador/Captain - <strong>Block Stealing</strong>: if other player tries to steal your coins, you block that attempt.</button></li>
    <li class="hover:bg-blue-800"><button phx-click="counteraction" phx-value-type={:block_foreign_aid}>Duke - <strong>Block Foreign Aid</strong>: counteraction. Prevents player to attempt foreign aid.</button></li>
    </ol>
    <p>General actions:</p>
    <ol>
    <li class="hover:bg-blue-800"><button phx-click="action" phx-value-type={:income}><strong>Income</strong>: +1 coin.</button></li>
    <li class="hover:bg-blue-800"><button phx-click="action" phx-value-type={:foreign_aid}><strong>Foreign Aid</strong>: +2 coins (can be blocked by the Duke).</button></li>
    <li class="hover:bg-blue-800"><button phx-click="action" phx-value-type={:coup}><strong>Coup</strong>: -7 coins and launch Coup agains another player. A coup cannot be blocked.</button></li>
    </ol>
    """
  end
end
