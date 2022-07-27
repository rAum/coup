defmodule CoupGameWeb.Lobby do
  use CoupGameWeb, :controller
  require Logger

  def join(conn, params) do
    %{"room_id" => room_id} = params

    user_name = MnemonicSlugs.generate_slug()
    user_id = UUID.uuid4()

    url = "/room/" <> room_id
    conn
      |> put_session(:user_name, user_name)
      |> put_session(:user_id, user_id)
      |> redirect(to: url)
  end

end
