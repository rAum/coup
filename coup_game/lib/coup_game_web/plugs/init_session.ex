defmodule CoupGameWeb.Plugs.InitSession do
  import Plug.Conn
  require Logger
  use CoupGameWeb, :controller
  alias CoupGameWeb.Router.Helpers, as: Helper

  @max_age 86400
  @salt "IxdmFm23"

  def init(opts), do: opts

  def fetch(conn) do
    Logger.info("KURWA no")
    token = conn
      |> Plug.Conn.get_session(:user_id)
      Logger.info("KURWA no #{token}")
    CoupGameWeb.Endpoint
      |> Phoenix.Token.verify(@salt, token, max_age: @max_age)
      |> maybe_load_user()
  end

  def create(conn) do
    user_id = UUID.uuid4()
    user_name = MnemonicSlugs.generate_slug()
    Logger.error("Creating new user token #{user_id}")

    token = Phoenix.Token.sign(CoupGameWeb.Endpoint, @salt, user_id)
    conn = conn
      |> put_session(:user_id, token)
      |> put_session(:user_name, user_name)
    conn
  end

  defp maybe_load_user({:ok, user_id}), do: user_id
  defp maybe_load_user({:error, err}) do
    Logger.error(err)
    nil
  end

  def call(conn, _opts) do
    Logger.warn("RUNNIG INIT SESSION PLUG")
    user_id = fetch(conn)
    Logger.warn(user_id)
    conn |> create(user_id)
  end

  defp create(conn, nil) do
    Logger.warn("Creating new session")
    create(conn)
  end

  defp create(conn, user_id) do
    Logger.warn("#{user_id} is existing session for the user")
    conn
  end

end
