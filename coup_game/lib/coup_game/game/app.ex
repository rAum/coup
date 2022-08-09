defmodule CoupGame.Game.App do
  use Supervisor
  alias CoupGame.Game.{Rooms, PlayerNames}

  @registry :game_rooms

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl Supervisor
  def init(_) do
    children = [
      {Registry, [keys: :unique, name: @registry]},
      PlayerNames,
      Rooms,
    ]
    opts = [strategy: :one_for_one]
    Supervisor.init(children, opts)
  end

end
