defmodule CoupGame.Card do
  @moduledoc """
  A struct representing card
  """

  @typedoc """
  Represents a single card from the deck
  """
  @type t() :: %__MODULE__{
    type: atom(),
    uuid: integer(),
    title: String.t(),
    description: String.t()
  }

  defstruct type: :blank,
            uuid: 0,
            title: "Unknown",
            description: "Unknown card"

end
