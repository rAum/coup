defmodule CoupGameWeb.Lobby do
  use CoupGameWeb, :controller
  require Logger

  def join(conn, %{"room_id" => room_id} = params) do
    Logger.warn("Joining room #{room_id} from lobby")
    Logger.info(params)
    Logger.warn("======================")

    create_or_reuse_session(conn, get_session(conn, :user_id), room_id)
  end

  defp create_or_reuse_session(conn, nil, _room_id) do
    Logger.error("No session. Redirect to home")
    conn
    |> redirect(to: "/")
  end

  defp create_or_reuse_session(conn, user_id, room_id) do
    Logger.info("Exisiting session for user [#{user_id}] is detected and going to #{room_id}")
    url = "/room/" <> room_id
    conn
    |> redirect(to: url)
  end

end
