defmodule CoupGameWeb.LobbyLive do
  use CoupGameWeb, :live_view
  alias CoupGame.Game.{Rooms, Room}
  require Logger


  @impl true
  def mount(_params, session, socket) do
    Logger.info("Mounting LobbyLive")
    Logger.warn(session)

    user_name = session
      |> Enum.find(nil, fn {a, _} -> a == "user_name" end)
      |> case do
        nil -> nil
        a -> a |> elem(1)
      end

    if user_name == nil do
      {:error, socket}
    else
      {:ok, assign(socket, user_name: user_name)}
    end
  end

  @impl true
  def handle_event("user-settings-change", change, socket) do
    Logger.info(">> #{inspect(change)}")
    new_name = String.trim(change["username"])
    socket =  case byte_size(new_name) do
      0 -> socket
      new_name -> assign(socket, user_name: new_name)
    end
    {:noreply, socket}
  end

  @impl true
  def handle_event("gen-random-room", _params, socket) do
    slug = "/room/join/" <> MnemonicSlugs.generate_slug(4)
    {:ok, room_pid} = Rooms.start_child(slug)
    user_name = socket.assigns.user_name
    Logger.info("Username when generating room[#{slug}]: #{user_name}")

    if user_name != nil do
      Room.add_player(room_pid, user_name)
    end

    Logger.info("Redirecting >>>> #{slug}")
    {:noreply, redirect(socket, to: slug)}
  end

  @impl true
  def handle_event("enter-room", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
     #
    ~H"""
    <section class="phx-hero">
    <h1><%= gettext "Welcome to %{name}!", name: "Coup Game" %></h1>
    <p><%= gettext "Card game implmented for the sake of learning new programming language and frameworks;)" %></p>
    <form phx-change="user-settings-change">
    <label for="username">Type your user name:</label><input type="text" id="username" name="username" value={@user_name}>
    <button phx-click="gen-random-room">Create new room</button>
    </form>
    <hr>
    <h2>Know secret code for existing game room?</h2>
    <form phx-submit="enter-room">
    <label for="secret">Secret code:</label>
    <input type="text" id="secret" name="secret">
    <button>Enter!</button>
    </form>
    </section>
    """
  end
end
