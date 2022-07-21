defmodule CoupGame.Repo do
  use Ecto.Repo,
    otp_app: :coup_game,
    adapter: Ecto.Adapters.Postgres
end
