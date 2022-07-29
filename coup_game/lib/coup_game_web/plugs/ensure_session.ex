defmodule CoupGameWeb.EnsureSession do
  import Plug.Conn
  use CoupGameWeb, :controller
  @max_age 86400
  @salt "IxdmFm23"
  require Logger

  def init(opts), do: opts

  def call(conn, _opts) do
    Logger.info("Running #{__MODULE__}")
    conn |> fetch() |> react(conn)
  end

  def fetch(conn) do
    token = conn |> Plug.Conn.get_session(:user_id)

    {status, _} = CoupGameWeb.Endpoint
                  |> Phoenix.Token.verify(@salt, token, max_age: @max_age)
    Logger.warn("#{__MODULE__} fetch ended with #{status}")
    status
  end

  def react(:ok, conn), do: conn
  def react(_, conn) do
    Logger.warn("User does not have session. Move to \"/\"")
    conn
    |> redirect(to: "/")
  end
end
