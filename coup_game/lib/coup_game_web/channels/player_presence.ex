defmodule CoupGameWeb.PlayerPresence do
  @moduledoc false
  use Phoenix.Presence,
    otp_app: :room_presence,
    pubsub_server: CoupGame.PubSub
end
