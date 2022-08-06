defmodule CoupGame.Game.RoomsCleaner do
  @moduledoc """
  Garbage collection of empty rooms
  """
  use GenServer
  require Logger

  @seconds 120

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def handle_info(:cleanup_time, state) do
    Logger.info("Cleanup time!")
    #TODO: hunt for empty rooms
    Process.send_after(self(), :cleanup_time, :timer.seconds(@seconds))
    {:noreply, state}
  end

  @impl true
  def init(_opts) do
    Logger.info("Starting a #{__MODULE__}")
    Process.send_after(self(), :cleanup_time, :timer.seconds(@seconds))
    {:ok, []}
  end

end
