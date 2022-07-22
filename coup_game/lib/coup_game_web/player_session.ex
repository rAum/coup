defmodule CoupGameWeb.PlayerSession do
  import Plug.Conn
  require Logger

  @max_age 86400
  @salt "IxdmFm23"

  def init(opts), do: opts

  def fetch(conn) do
    token = conn
      |> Plug.Conn.fetch_session()
      |> Plug.Conn.get_session(:user_id)

    CoupGameWeb.Endpoint
      |> Phoenix.Token.verify(@salt, token, max_age: @max_age)
      |> maybe_load_user()
  end

  def create(conn) do
    user = MnemonicSlugs.generate_slug()
    Logger.error("Creating new user #{user}")

    token = Phoenix.Token.sign(CoupGameWeb.Endpoint, @salt, user)
    conn
      |> Plug.Conn.fetch_session()
      |> put_session(:user_id, token)
    user
  end

  defp maybe_load_user({:ok, user_id}), do: user_id
  defp maybe_load_user({:error, _any}), do: nil

  def call(conn, _opts) do
    user = fetch(conn)
    Logger.info("Fetch returned #{user}")
    if user == nil do
      user = create(conn)
      assign(conn, :current_user, user)
    else
      assign(conn, :current_user, user)
    end

  end
end
