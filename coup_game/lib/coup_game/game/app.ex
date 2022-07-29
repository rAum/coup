defmodule CoupGame.Game.App do
  use Supervisor
  alias CoupGame.Game.{Rooms, RoomsCleaner}

  @registry :game_rooms
  @player_names :player_names

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init([]) do
    children = [
      {Registry, [keys: :unique, name: @registry]},
      {Registry, [keys: :unique, name: @player_names]},
      Rooms,
      #RoomsCleaner,
    ]
    Supervisor.init(children, [strategy: :one_for_one, name: __MODULE__])
  end

end
