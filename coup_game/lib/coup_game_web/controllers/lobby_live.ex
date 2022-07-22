defmodule CoupGameWeb.LobbyLive do
  use CoupGameWeb, :live_view
  require Logger


  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, query: "", results: %{} )}
  end

  @impl true
  def handle_event("gen-random-room", _params, socket) do
    slug = "/room/" <> MnemonicSlugs.generate_slug(4)
    Logger.info(slug)
    {:noreply, push_redirect(socket, to: slug)}
  end

  @impl true
  def handle_event("enter-room", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <section class="phx-hero">
    <h1><%= gettext "Welcome to %{name}!", name: "Coup Game" %></h1>
    <p><%= gettext "Card game implmented for the sake of learning new programming language and frameworks;)" %></p>
    <label for="username">Type your user name:</label><input type="text" id="username" name="username">
    <button phx-click="gen-random-room">Create new room</button>
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
