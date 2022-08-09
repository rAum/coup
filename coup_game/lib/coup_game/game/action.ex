defmodule CoupGame.Game.Action do
    @moduledoc """
  A struct representing actions in game
  """

  @typedoc """
  Represents a single card from the deck
  """
  @type t() :: %__MODULE__{
    type: atom(),
    origin: String.t(),
    target: String.t(),
  }

  defstruct type: :nop,
            origin: "",
            target: ""


  def make_coup(origin, target) do
    %__MODULE__{type: :coup, origin: origin, target: target}
  end
end
