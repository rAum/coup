defmodule CoupGame.Game.State do
      @moduledoc """
  A struct representing all states of the game
  """

  @typedoc """
  Represents a single card from the deck
  """
  @type t() :: %__MODULE__{
    coins: list(integer()),
    turn: integer(),
    turn_order: list(charlist()),
    court: list(CoupGame.Card.t()),
    hands: map(),
    game_stack: list(),
    players: nonempty_list()
  }

  defstruct [:players,
            coins: [],
            turn: 0,
            turn_order: [],
            court: [],
            hands: [],
            game_stack: []]

  @spec new(list) :: :error | %__MODULE__{}
  def new([]), do: :error
  def new([_]), do: :error
  def new(players) when is_list(players) do
    if length(players) <= 7 do
      create_new(players)
    else
      :error
    end
  end
  def new(_), do: :error

  def public_states(), do: [:coins, :turn, :turn_order]

  defp create_new(players) do
    n = Enum.count(players)
    {court_deck, player_decks} = CoupGame.Carddeck.deal_deck(n)
    player_hands = Enum.zip([players, player_decks])
    |> Enum.into(%{})

    turn_order = players
                |> Enum.shuffle()
                |> Enum.with_index()
                |> Enum.into(%{})

    %__MODULE__{
      players: players,
      coins: Enum.zip([players, Stream.repeatedly(fn -> 2 end)]) |> Enum.into(%{}),
      turn: 0,
      turn_order: turn_order,
      court: court_deck,
      hands: player_hands,
    }
  end
end
