defmodule CoupGame.Game.Room do
  use GenServer
  alias CoupGame.Carddeck, as: Deck
  require Logger

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  def log_state(process_name) do
    process_name |> via_tuple() |> GenServer.call(:log_state)
  end

  def start_game(pid) when is_pid(pid) do
    pid |> GenServer.cast({:start_game})
  end

  def add_player(pid, player_name) when is_pid(pid) do
    pid |> GenServer.call({:add_player, player_name})
  end

  def add_player(process_name, player_name) do
    process_name |> via_tuple() |> GenServer.call({:add_player, player_name})
  end

  def get_player_hand(pid, player_name) when is_pid(pid) do
    pid |> GenServer.call({:get_hand, player_name})
  end

  def get_public_state(process_name) do
    process_name |> via_tuple() |> GenServer.call(:get_public_state)
  end

  def take_action(process_name, player_id, command) do
    process_name |> via_tuple() |> GenServer.cast({:action, player_id, command})
  end

  def exists(process_name) do
    process_name |> via_tuple() |> GenServer.whereis()
  end

  def stop(process_name, reason \\ :normal) do
    process_name |> via_tuple() |> GenServer.stop(reason)
  end

  def child_spec(process_name) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [process_name]},
      restart: :transient
    }
  end
################################

  @impl true
  def handle_call(:log_state, _from, state) do
    {:reply, "State: #{inspect(state)}", state}
  end

  @impl true
  def handle_call(:get_public_state, _from, state) do
    {public_state, _} = Map.split(state, [:turn, :turn_order, :coins])
    {:reply, public_state, state}
  end

  @impl true
  def handle_call({:add_player, new_player}, _from, state) do
    new_state = Map.update!(state, :players, fn existing -> [new_player | existing] end)
    Logger.info("add player")
    {:reply, :player_added, new_state}
  end

  @impl true
  def handle_call({:get_hand, player_id}, _from, %{hands: hands} = state) do
    {:reply, hands[player_id], state}
  end

  @impl true
  def handle_call({:get_hand, _}, _from, state) do
    {:reply, [], state}
  end

  @impl true
  def handle_cast({:start_game}, state) do
    Logger.info("Starting game in room")
    n = Enum.count(state.players)
    {court_deck, player_decks} = Deck.deal_deck(n)

    player_hands = Enum.zip([state.players, player_decks])
    |> Enum.into(%{})

    turn_order = state.players |> Enum.shuffle() |> Enum.with_index() |> Enum.into(%{})
    new_state = %{
      court: court_deck,
      hands: player_hands,
      coins: Enum.zip([state.players, Stream.repeatedly(fn -> 2 end)]) |> Enum.into(%{}),
      turn: 0,
      turn_order: turn_order,
    }
    state = Map.merge(state, new_state)
    Logger.info("Game is ON! #{inspect(state)}")

    CoupGameWeb.Endpoint.broadcast(state.room_id, "game_update", nil)
    {:noreply, state}
  end

  @impl true
  def handle_cast({:action, player_id, command}, state) do
    Logger.info("Taking action #{player_id} #{inspect(command)}")
    state = action(command, player_id, state)
    CoupGameWeb.Endpoint.broadcast(state.room_id, "game_update", nil)
    {:noreply, state}
  end

  @impl true
  def init(opts) do
    Logger.info("Opening new game room.. #{inspect(opts)}")
    initial_state = %{
      players: [],
      room_id: opts,
      game_stack: [],
    }
    {:ok, initial_state}
  end

  defp via_tuple(process_name) do
    {:via, Registry, {:game_rooms, process_name}}
  end

  defp action("income", player_id, state) do
    new_coins = state.coins
    |> Map.update(player_id, 0, &(&1 + 1))
    state = %{state| :coins => new_coins}
    next_turn(state)
  end

  defp action(type, _, state) do
    Logger.error("Incorrect action #{inspect(type)}")
    state
  end

  defp next_turn(state) do
    n = state.players |> Enum.count()
    %{state | turn: rem(state.turn + 1, n)}
  end

end
