defmodule CoupGame.Game.App do
  use Supervisor
  alias CoupGame.Game.{Rooms, RoomsCleaner, PlayerNames}

  @registry :game_rooms

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init([]) do
    children = [
      {Registry, [keys: :unique, name: @registry]},
      PlayerNames,
      Rooms,
      #RoomsCleaner,
    ]
    Supervisor.init(children, [strategy: :one_for_one, name: __MODULE__])
  end

end
