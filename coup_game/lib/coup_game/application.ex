defmodule CoupGame.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      CoupGame.Repo,
      # Start the Telemetry supervisor
      CoupGameWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: CoupGame.PubSub},
      # This implemnets presence, so must be between pubsub/endpoint
      CoupGameWeb.GameRoomLive,
      # Start the Endpoint (http/https)
      CoupGameWeb.Endpoint
      # Start a worker by calling: CoupGame.Worker.start_link(arg)
      # {CoupGame.Worker, arg}
    ]

    :ets.new(:session, [:named_table, :public, read_concurrency: true])

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CoupGame.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CoupGameWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
