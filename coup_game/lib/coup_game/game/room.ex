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

  def add_player(pid, player_name) when is_pid(pid) do
    pid |> GenServer.call({:add_player, player_name})
  end

  def add_player(process_name, player_name) do
    process_name |> via_tuple() |> GenServer.call({:add_player, player_name})
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
  def handle_call({:add_player, new_player}, _from, state) do
    new_state = Map.update!(state, :players, fn existing -> [new_player | existing] end)
    {:reply, :player_added, new_state}
  end

  @impl true
  def init(opts) do
    Logger.info("Starting game room.. #{inspect(opts)}")
    initial_state = %{players: [], cards: Deck.generate_carddeck() }
    {:ok, initial_state}
  end

  defp via_tuple(process_name) do
    {:via, Registry, {:game_rooms, process_name}}
  end

end
