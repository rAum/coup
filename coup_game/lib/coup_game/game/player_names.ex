defmodule CoupGame.Game.PlayerNames do
  use GenServer
  require Logger

  @kv_name :player_names

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def handle_cast({:insert, id_name_pair}, state) do
    Logger.info("Adding a new pair #{inspect(id_name_pair)}")
    :ets.insert(@kv_name, id_name_pair)
    {:noreply, state}
  end

  @impl true
  def handle_call(id, _from, state) do
    result = :ets.lookup(@kv_name, id)
    {:reply, result, state}
  end

  def name do
    @kv_name
  end

  def lookup(user_id) do
    GenServer.call(__MODULE__, user_id)
  end

  def add_update(user_id, user_name) do
    GenServer.cast(__MODULE__, {:insert, {user_id, user_name}})
  end

  ############
  @impl true
  def init(_opts) do
    :ets.new(@kv_name, [:set, :protected, :named_table])
    {:ok, []}
  end

end
