defmodule CoupGame.Game.Rooms do
  @moduledoc """
  This module implements a supervisior for dynamically creating game rooms.
  """
  use DynamicSupervisor
  alias CoupGame.Game.Room
  require Logger

  def start_link(arg) do
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def start_child(game_name) do
    child_spec = {Room, game_name}
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def kill_child(pid) do
    DynamicSupervisor.terminate_child(__MODULE__, pid)
  end

  @impl true
  def init(_opts) do
    Logger.info("Init a dynamic game master services")
    DynamicSupervisor.init(strategy: :one_for_one)
  end

end
